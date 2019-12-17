//
//  CourseKits.swift
//  Electsys Utility
//
//  Created by 法好 on 2019/9/15.
//  Copyright © 2019 yuxiqian. All rights reserved.
//

import Alamofire
import Alamofire_SwiftyJSON
import Foundation
import SwiftyJSON

class CourseKits {
    static func requestCourseTable(year: Int, term: Int,
                                   handler: @escaping ([NGCourse]) -> Void,
                                   failure: @escaping (Int) -> Void) {
        // 1 - "3"
        // 2 - "12"
        // 3 - "16"
        if term < 1 || term > 3 {
            failure(-1)
            return
        }
        let termString = CourseConst.termTable[term]

        let getParams: Parameters = [
            "xnm": year,
            "xqm": termString,
        ]

        Alamofire.request(CourseConst.requestUrl,
                          method: .get,
                          parameters: getParams).responseSwiftyJSON(completionHandler: { responseJSON in
            if responseJSON.error == nil {
                let jsonResp = responseJSON.value
                if jsonResp != nil {
                    if !PreferenceKits.hidePersonalInfo {
                        IdentityKits.studentId = jsonResp?["xsxx"]["XH"].string
                        IdentityKits.studentName = jsonResp?["xsxx"]["XM"].string
                        IdentityKits.studentNameEn = jsonResp?["xsxx"]["YWXM"].string
                    }

                    var courseList: [NGCourse] = []

                    for courseObject in jsonResp?["kbList"].arrayValue ?? [] {
                        let teachers = courseObject["xm"].stringValue.components(separatedBy: ",")
                        let teacherTitles = courseObject["zcmc"].stringValue.components(separatedBy: ",")
                        let dayArrangeArray = courseObject["jcs"].stringValue.components(separatedBy: ",")

                        for dayArrStr in dayArrangeArray {
                            var dayArrangeList = dayArrStr.components(separatedBy: "-")
                            if dayArrangeList.count != 2 {
                                if dayArrangeList.count == 1 {
                                    dayArrangeList.append(dayArrangeList[0])
                                } else {
                                    NSLog("failed to parse dayArrangeList " + (courseObject.rawString() ?? "<json>"))
                                    continue
                                }
                            }
                            let weekArrDataList = courseObject["zcd"].stringValue.components(separatedBy: CharacterSet(charactersIn: ";,"))

                            for weekArrData in weekArrDataList {
                                var weekArrangeList = weekArrData.components(separatedBy: CharacterSet(charactersIn: "-周"))
                                if weekArrangeList.count == 1 {
                                    weekArrangeList.append(weekArrangeList[0])
                                }

                                if weekArrangeList[1] == "" {
                                    weekArrangeList[1] = weekArrangeList[0]
                                }

                                var dualType = ShiftWeekType.Both

                                if weekArrData.contains("(单)") {
                                    dualType = .OddWeekOnly
                                } else if weekArrData.contains("(双)") {
                                    dualType = .EvenWeekOnly
                                }

                                let dayStartsAtInt = Int(dayArrangeList[0])
                                let dayEndsAtInt = Int(dayArrangeList[1])
                                let weekStartsAtInt = Int(weekArrangeList[0])
                                let weekEndsAtInt = Int(weekArrangeList[1])

                                if dayStartsAtInt == nil {
                                    NSLog("failed to convert dayStartsAt (\(dayArrangeList[0])) to string of " + (courseObject["zcd"].string ?? "<json>"))
                                    continue
                                }

                                if dayEndsAtInt == nil {
                                    NSLog("failed to convert dayEndsAt (\(dayArrangeList[1])) to string of " + (courseObject["zcd"].string ?? "<json>"))
                                    continue
                                }

                                if weekStartsAtInt == nil {
                                    NSLog("failed to convert weekStartsAt (\(weekArrangeList[0])) to string of " + (courseObject["zcd"].string ?? "<json>"))
                                    continue
                                }

                                if weekEndsAtInt == nil {
                                    NSLog("failed to convert weekEndsAt (\(weekArrangeList[1])) to string of " + (courseObject["zcd"].string ?? "<json>"))
                                    continue
                                }

                                courseList.append(NGCourse(courseIdentifier: courseObject["jxbmc"].stringValue,
                                                           courseCode: courseObject["kch_id"].stringValue,
                                                           courseName: courseObject["kcmc"].stringValue,
                                                           courseTeacher: teachers,
                                                           courseTeacherTitle: teacherTitles,
                                                           courseRoom: courseObject["cdmc"].stringValue,
                                                           courseDay: courseObject["xqj"].intValue,
                                                           courseScore: courseObject["xf"].floatValue,
                                                           dayStartsAt: dayStartsAtInt!,
                                                           dayEndsAt: dayEndsAtInt!,
                                                           weekStartsAt: weekStartsAtInt!,
                                                           weekEndsAt: weekEndsAtInt!,
                                                           shiftWeek: dualType,
                                                           notes: courseObject["xkbz"].stringValue))
                            }
                        }
                    }
                    handler(courseList)
                } else {
                    failure(-3)
                }
            } else {
                failure(-2)
            }
        })
    }
}
