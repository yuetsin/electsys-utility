//
//  LegacyHtmlParser.swift
//  Sync Utility
//
//  Created by yuxiqian on 2018/8/31.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Kanna
import Foundation
import Regex




func parseCourseSheet(_ docContent: String,
//                      _ courseInfoArray: inout [Course],
                      _ displayWeek: inout [Day],
                      _ isSummerTerm: Bool = false) {
//    print("收到：\(docContent)")

//    var isSummerTerm = false
//    var trIndex = 0, tdIndex = 0
    var courseNameArray: [Course] = []
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
                            courseNameArray.append(Course(courseProp[1] , identifier: courseProp[0] , CourseScore: Float(courseProp[2]) ?? 0.0))
                        }
                    }
                }
            }
        }
        
        parseTimeTable(html,
                       "//*[@id=\"LessonTbl1_spanContent\"]/table",
                       &courseNameArray,
//                       &courseInfoArray,
                       &displayWeek)
        // 解析普通学期
        
        if (isSummerTerm) {
            // 如果解析暑期学期
            parseTimeTable(html, "//*[@id=\"LessonTbl1_span1\"]/table",
                           &courseNameArray,
//                           &courseInfoArray,
                           &displayWeek,
                           isSummerTerm: true)
        }
//        }
        // 暑期小学期 selector:
        // "#LessonTbl1_span1 > table > tbody > tr:nth-child(2) > td > table > tbody"
    }
}

fileprivate func parseTimeTable(_ html: HTMLDocument,
                                _ xpath: String,
                                _ rawCourseArray: inout [Course],
//                                _ courseArray: inout [Course],
                                _ displayWeek: inout [Day],
                                isSummerTerm: Bool = false) {
    for timeTable in html.xpath(xpath) {
        if let timeTableDetail = try? HTML(html: timeTable.toHTML!, encoding: .utf8) {
            var timeIndex = 1
            if isSummerTerm {
                timeIndex = 0
                // 暑期小学期课表表头有多余的一行。
                // 需要特殊处理。
            }
            for weekDay in timeTableDetail.xpath("//tr[position()>1]") {
                if let dayTimeDetail = try? HTML(html: weekDay.toHTML!, encoding: .utf8) {
                    var weekDayNum = 1
                    for lessonTime in dayTimeDetail.xpath("//td[position()>1]") {
                        if weekDayNum >= 7 {
                            break
                        }
                        // detect lessonName
                        let lessonName = sanitize(lessonTime.text ?? "")
                        if lessonName.contains("单周") && lessonName.contains("双周") {
                            if lessonName.hasSuffix("双周") {
//                                print ("单 + 双周模式：\(lessonName) 将被拆分。")
                                var splited = lessonName.components(separatedBy: "单周")
//                                print ("分裂1：\(splited[0] + "单周")，分裂2:\(splited[1])")
                                if (checkIfWordyExpress(splited[0], splited[1])) {
                                    createCourse(combineWordyExpress(splited[0], splited[1]),
                                                 lessonTime.toHTML!,
                                                 &weekDayNum,
                                                 timeIndex,
                                                 &displayWeek,
   //                                             &courseArray,
                                                &rawCourseArray,
                                                ShiftWeekType.Both,
                                                isSummerTerm)
                                } else {
                                    createCourse(splited[0] + "单周",
                                                 lessonTime.toHTML!,
                                                 &weekDayNum,
                                                 timeIndex,
                                                 &displayWeek,
    //                                             &courseArray,
                                                 &rawCourseArray,
                                                 ShiftWeekType.OddWeekOnly,
                                                 isSummerTerm)
                                    createCourse(splited[1],
                                                 lessonTime.toHTML!,
                                                 &weekDayNum,
                                                 timeIndex,
                                                 &displayWeek,
    //                                             &courseArray,
                                                 &rawCourseArray,
                                                 ShiftWeekType.EvenWeekOnly,
                                                 isSummerTerm)
                                }
                            } else if lessonName.hasSuffix("单周") {
//                                print ("双 + 单周模式：\(lessonName) 将被拆分。")
                                var splited = lessonName.components(separatedBy: "双周")
//                                print ("分裂1：\(splited[0] + "双周")，分裂2:\(splited[1])")
                                if (checkIfWordyExpress(splited[0], splited[1])) {
                                    createCourse(combineWordyExpress(splited[0], splited[1]),
                                                 lessonTime.toHTML!,
                                                 &weekDayNum,
                                                 timeIndex,
                                                 &displayWeek,
                                                 //                                             &courseArray,
                                        &rawCourseArray,
                                        ShiftWeekType.Both,
                                        isSummerTerm)
                                } else {
                                    createCourse(splited[0] + "双周",
                                                 lessonTime.toHTML!,
                                                 &weekDayNum,
                                                 timeIndex,
                                                 &displayWeek,
    //                                             &courseArray,
                                                 &rawCourseArray,
                                                 ShiftWeekType.EvenWeekOnly,
                                                 isSummerTerm)
                                    createCourse(splited[1],
                                                 lessonTime.toHTML!,
                                                 &weekDayNum,
                                                 timeIndex,
                                                 &displayWeek,
    //                                             &courseArray,
                                                 &rawCourseArray,
                                                 ShiftWeekType.OddWeekOnly,
                                                 isSummerTerm)
                                }
                            }
                        } else if lessonName.contains("单周") {
                            createCourse(lessonName,
                                         lessonTime.toHTML!,
                                         &weekDayNum,
                                         timeIndex,
                                         &displayWeek,
//                                         &courseArray,
                                         &rawCourseArray,
                                         ShiftWeekType.OddWeekOnly,
                                         isSummerTerm)
                        } else if lessonName.contains("双周") {
                            createCourse(lessonName,
                                         lessonTime.toHTML!,
                                         &weekDayNum,
                                         timeIndex,
                                         &displayWeek,
//                                         &courseArray,
                                         &rawCourseArray,
                                         ShiftWeekType.EvenWeekOnly,
                                         isSummerTerm)
                        } else {
                            createCourse(lessonName,
                                         lessonTime.toHTML!,
                                         &weekDayNum,
                                         timeIndex,
                                         &displayWeek,
//                                         &courseArray,
                                         &rawCourseArray,
                                         ShiftWeekType.Both,
                                         isSummerTerm)
                        }
                        weekDayNum += 1
                    }
                }
                timeIndex += 1
            }
        }
    }
}

fileprivate func createCourse(_ lessonName: String,
                              _ innerHTML: String,
                              _ weekDayNum: inout Int,
                              _ timeIndex: Int,
                              _ displayWeek: inout [Day],
//                              _ courseArray: inout [Course],
                              _ rawCourseArray: inout [Course],
                              _ shiftType: ShiftWeekType,
                              _ isSummerTerm: Bool) {
    
    //                        print("lessonName = \(lessonName)")
    //                        print("Now, it's weekDay No.\(weekDay)")
    //                        print("Now it's courseTime No.\(timeIndex)")
    // detect lesson duration
    var lessonDuration = 0
    if let lessonNode = try? HTML(html: innerHTML, encoding: .utf8) {
        lessonDuration = Int(lessonNode.xpath("//@rowspan").first?.text ?? "0") ?? 0
    }
    if lessonDuration == 0 {
        return
    }
    
    let index = findIndexOfCourseByName(name: getCourseName(lessonName), array: rawCourseArray)
    if index == -1 {
        return
    }
    let newCourse = Course(rawCourseArray[index].courseName, identifier: rawCourseArray[index].courseIdentifier,
                           CourseScore: rawCourseArray[index].courseScore)
    newCourse.courseRoom = getCourseRoom(lessonName)
//    newCourse.courseRoom = clearBrackets(("(\\[[^\\]]*\\])".r?.findFirst(in: lessonName)?.group(at: 1)) ?? "未知")
    newCourse.courseDuration = lessonDuration
    newCourse.dayStartsAt = timeIndex
    newCourse.shiftWeek = shiftType
    
    
    let weekSchedule = lessonName.replacingOccurrences(of: newCourse.courseName, with: "")
//
//    print("(?<=（)[^-]+".r?.findFirst(in: weekSchedule)?.group(at: 0) ?? "0")
//    print("(?<=-)[^周）]+".r?.findFirst(in: weekSchedule)?.group(at: 0) ?? "0")
    let startWeek = getStartWeek(weekSchedule)
    let endWeek = getEndWeek(weekSchedule)
//    let startWeek = Int("(?<=（)[^-]+".r?.findFirst(in: weekSchedule)?.group(at: 0) ?? "0") ?? 0
//    let endWeek = Int("(?<=-)[^周）]+".r?.findFirst(in: weekSchedule)?.group(at: 0) ?? "0") ?? 0
    

    
    newCourse.setWeekDuration(start: startWeek, end: endWeek)
    
    var flag = true
    while flag {
        flag = false
        for course in displayWeek[weekDayNum].children {
//            print("判断\(course.courseName)与\(newCourse.courseName)是否冲突…")
            if course.judgeIfConflicts(newCourse, summerMode: isSummerTerm) {
//                print ("\(course.courseName)与\(newCourse.courseName) 课程冲突。移位一次。")
                flag = true
                break
            }
        }
        if flag {
            weekDayNum += 1
//            print("完成一次移动位置。")
        } else {
            break
        }
    }
    
//    print("开始于周\(startWeek)，终止于周\(endWeek)的课程：")
//
//    print("星期\(weekDayNum), 原始名称 \(lessonName), 节数  \(timeIndex) ~ \(timeIndex + lessonDuration - 1), 教室在 \(newCourse.courseRoom)")
    
    newCourse.courseDay = weekDayNum
    
//    courseArray.append(newCourse)
    displayWeek[weekDayNum].children.append(newCourse)
}
