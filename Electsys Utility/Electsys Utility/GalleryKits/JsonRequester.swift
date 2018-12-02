//
//  JsonRequester.swift
//  Electsys Utility
//
//  Created by yuxiqian on 2018/9/16.
//  Copyright © 2018/9/16 yuxiqian. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

let jsonHeader = "https://raw.githubusercontent.com/yuxiqian/finda-studyroom/master/json_output/"

func generateCur(_ json: JSON) -> Curricula {
    let cur = Curricula()
    cur.identifier = json["identifier"].stringValue
    cur.holderSchool = json["holder_school"].stringValue.sanitize()
    
    let splitHolderSchool = cur.holderSchool.components(separatedBy: CharacterSet(charactersIn: "()"))
    if splitHolderSchool.count > 2 {
        if Int(splitHolderSchool[1]) != nil {
            cur.holderSchool = splitHolderSchool[2]
//            print("truncated \(cur.holderSchool)")
        } else {
//            print("misfire \(splitHolderSchool[1])")
        }
    }
    
    cur.name = json["name"].stringValue.sanitize()
    cur.year = Year(rawValue: json["year"].intValue) ?? .__BAD_YEAR
    cur.targetGrade = json["target_grade"].intValue
    cur.teacherName = json["teacher"].stringValue.sanitize()
    cur.teacherTitle = json["teacher_title"].stringValue
    cur.creditScore = json["credit"].floatValue
    cur.startWeek = json["start_week"].intValue
    cur.endWeek = json["end_week"].intValue
    cur.studentNumber = json["student_number"].intValue
    cur.notes = json["notes"].stringValue.deleteOccur(remove: "&nbsp").sanitize()
    
    if let oddWeekArr = json["odd_week"].array {
        for owa in oddWeekArr {
            let a = Arrangement()
            a.weekDay = owa["week_day"].intValue
            a.startsAt = owa["start_from"].intValue
            a.endsAt = owa["end_at"].intValue
            a.classroom = owa["classroom"].stringValue.replacingOccurrences(of: "教学一楼", with: "教一楼")
            // .replacingOccurrences(of: "教一楼", with: "徐汇教一楼").replacingOccurrences(of: "新上院", with: "徐汇新上院").replacingOccurrences(of: "工程馆", with: "徐汇工程馆").replacingOccurrences(of: "西二楼", with: "卢湾西二楼").replacingOccurrences(of: "图书馆", with: "卢湾图书馆")
            let splitedClassroom = a.classroom.components(separatedBy: CharacterSet(charactersIn: "(/)"))
            if (splitedClassroom.count >= 3) {
                a.classroom = splitedClassroom[0].sanitize() + splitedClassroom[2]
            }
            if (sanitize(a.classroom) == "") {
                a.classroom = splitedClassroom[0].sanitize() + "校区"
            }
            cur.oddWeekArr.append(a)
        }
    }
    
    if let evenWeekArr = json["even_week"].array {
        for ewa in evenWeekArr {
            let a = Arrangement()
            a.weekDay = ewa["week_day"].intValue
            a.startsAt = ewa["start_from"].intValue
            a.endsAt = ewa["end_at"].intValue
            a.classroom = ewa["classroom"].stringValue.replacingOccurrences(of: "教学一楼", with: "教一楼")
            // .replacingOccurrences(of: "教一楼", with: "徐汇教一楼").replacingOccurrences(of: "新上院", with: "徐汇新上院").replacingOccurrences(of: "工程馆", with: "徐汇工程馆").replacingOccurrences(of: "西二楼", with: "卢湾西二楼").replacingOccurrences(of: "图书馆", with: "卢湾图书馆")
            let splitedClassroom = a.classroom.components(separatedBy: CharacterSet(charactersIn: "(/)"))
            if (splitedClassroom.count >= 3) {
                a.classroom = splitedClassroom[0].sanitize() + splitedClassroom[2]
            }
            if (sanitize(a.classroom) == "") {
                a.classroom = splitedClassroom[0].sanitize() + "校区"
            }
            cur.evenWeekArr.append(a)
        }
    }
    return cur
}

func hanToInt(_ str: String?) -> Int {
    if str == nil { return -1 }
    for i in 1...22 {
        if str == "第 \(i) 周" {
            return i
        }
    }
    return 0
}

let dayToInt = ["", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六", "星期日", ]
