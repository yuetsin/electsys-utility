//
//  HtmlParser.swift
//  Sync Utility
//
//  Created by yuxiqian on 2018/8/31.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Kanna
import Foundation
import Regex

fileprivate func parseTimeTable(_ html: HTMLDocument, _ xpath: String, _ rawCourseArray: inout [Course], _ week: inout Week, isOddWeek: Bool = false) {
    for timeTable in html.xpath(xpath) {
        if let timeTableDetail = try? HTML(html: timeTable.toHTML!, encoding: .utf8) {
            var timeIndex = 1
            for weekDay in timeTableDetail.xpath("//tr[position()>1]") {

                if let dayTimeDetail = try? HTML(html: weekDay.toHTML!, encoding: .utf8) {
                    var weekDayNum = 1
                    for lessonTime in dayTimeDetail.xpath("//td[position()>1]") {
                        if weekDayNum >= 7 {
                            break
                        }
                        // detect lessonName
                        let lessonName = sanitize(lessonTime.text ?? "")
//                        print("lessonName = \(lessonName)")
//                        print("Now, it's weekDay No.\(weekDay)")
//                        print("Now it's courseTime No.\(timeIndex)")
                        // detect lesson duration
                        var lessonDuration = 0
                        if let lessonNode = try? HTML(html: lessonTime.toHTML!, encoding: .utf8) {
                            lessonDuration = Int(lessonNode.xpath("//@rowspan").first?.text ?? "0") ?? 0
                        }
                        
                        while
                            (week.days[weekDayNum - 1].children.last?.courseStartsAt ?? 0) +
                                (week.days[weekDayNum - 1].children.last?.courseDuration ?? 0) - 1 > timeIndex {
                            weekDayNum += 1
                        }
                        
                        if lessonName.contains("单周") && !lessonName.contains("双周") {
                            
                        }
                        
                        if !(lessonName.contains("单周") || lessonName.contains("双周")) {
                            if lessonDuration != 0 {
                                let index = findIndexOfCourseByName(name: lessonName, array: rawCourseArray)
                                if index != -1 {
                                    let newCourse = Course(rawCourseArray[index].courseName, identifier: rawCourseArray[index].courseIdentifier,
                                           CourseScore: rawCourseArray[index].courseScore)
                                    newCourse.courseRoom = clearBrackets(("(\\[[^\\]]*\\])".r?.findFirst(in: lessonName)?.group(at: 1)) ?? "未知")
                                    newCourse.courseDuration = lessonDuration
                                    newCourse.courseStartsAt = timeIndex
                                    week.days[weekDayNum - 1].children.append(newCourse)
                                    print("weekday: \(weekDayNum), append name: \(lessonName), startTime = \(timeIndex), room = \(newCourse.courseRoom), duration = \(lessonDuration)")
                                }
                            }
                        } else {

                        }
                        weekDayNum += 1
                    }
                }
                timeIndex += 1
            }
        }
    }
}

func parseCourseSheet(_ docContent: String, week: inout Week, isSummerTerm: Bool = false) {
//    print("收到：\(docContent)")

//    var isSummerTerm = false
//    var trIndex = 0, tdIndex = 0
    var rawCourseArray: [Course] = []
    if let html = try? HTML(html: docContent, encoding: .utf8) {
        for dataGrid in html.xpath("//*[@id=\"Datagrid1\"]") {
            if let detailTable = try? HTML(html: dataGrid.toHTML!, encoding: .utf8) {
                for course in detailTable.xpath("//tr[position()>1]") {
                    if let properties = try? HTML(html: course.toHTML!, encoding: .utf8) {
                        var courseProp: [String] = []
                        for propItem in properties.xpath("//td") {
                            courseProp.append(propItem.text ?? "Nil")
                        }
                        if courseProp.count >= 3 {
                            rawCourseArray.append(Course(courseProp[1] , identifier: courseProp[0] , CourseScore: Float(courseProp[2]) ?? 0.0))
                        }
                    }
                }
            }
        }
        if (isSummerTerm) {
            // 如果解析暑期学期
            parseTimeTable(html, "//*[@id=\"LessonTbl1_span1\"]/table", &rawCourseArray, &week)
        } else {
            parseTimeTable(html, "//*[@id=\"LessonTbl1_spanContent\"]/table", &rawCourseArray, &week)
        }
        // 暑期小学期 selector:
        // "#LessonTbl1_span1 > table > tbody > tr:nth-child(2) > td > table > tbody"
    }
}
