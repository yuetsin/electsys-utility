//
//  HtmlParser.swift
//  Sync Utility
//
//  Created by yuxiqian on 2018/8/31.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Kanna
import Foundation

fileprivate func parseTimeTable(_ html: HTMLDocument, _ xpath: String, _ rawCourseArray: inout [Course], _ array: inout [SchoolDay]) {
    for timeTable in html.xpath(xpath) {
        if let timeTableDetail = try? HTML(html: timeTable.toHTML!, encoding: .utf8) {
            var timeIndex = 1
            for weekDay in timeTableDetail.xpath("//tr[position()>1]") {
                //                    print("Now it's courseTime No.\(timeIndex)")
                if let dayTimeDetail = try? HTML(html: weekDay.toHTML!, encoding: .utf8) {
                    var weekDayNum = 1
                    for lessonTime in dayTimeDetail.xpath("//td[position()>1]") {
                        if weekDayNum > 7 {
                            break
                        }
                        let lessonName = sanitize(lessonTime.text ?? "")
                        //                            print("lessonName = \(lessonName)")
                        //                            print("Now, it's weekDay No.\(weekDay)")
                        var lessonDuration = 0
                        if let lessonNode = try? HTML(html: lessonTime.toHTML!, encoding: .utf8) {
                            lessonDuration = Int(lessonNode.xpath("//@rowspan").first?.text ?? "0") ?? 0
                        }
                        if lessonDuration != 0 {
                            let index = findIndexOfCourseByName(name: lessonName, array: rawCourseArray)
                            if index != -1 {
                                rawCourseArray[index].courseDuration = lessonDuration
                                rawCourseArray[index].courseStartsAt = timeIndex
                                array[weekDayNum - 1].children.append(rawCourseArray[index])
                                //                                    print("weekday: \(weekDayNum), append name: \(lessonName), startTime = \(timeIndex), duration = \(lessonDuration)")
                            }
                        }
                        weekDayNum += 1
                    }
                }
                timeIndex += 1
            }
        }
    }
}

func parseCourseSheet(_ docContent: String, array: inout [SchoolDay]) {
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
        parseTimeTable(html, "//*[@id=\"LessonTbl1_spanContent\"]/table", &rawCourseArray, &array)
        parseTimeTable(html, "//*[@id=\"LessonTbl1_span1\"]/table", &rawCourseArray, &array)
        // 暑期小学期 selector:
        // "#LessonTbl1_span1 > table > tbody > tr:nth-child(2) > td > table > tbody"
    }
}
