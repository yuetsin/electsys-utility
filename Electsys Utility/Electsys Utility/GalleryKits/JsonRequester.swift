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
    cur.holderSchool = json["holder_school"].stringValue
    cur.name = json["name"].stringValue
    cur.year = Year(rawValue: json["year"].intValue)!
    cur.targetGrade = json["target_grade"].intValue
    cur.teacherName = json["teacher"].stringValue
    cur.teacherTitle = json["teacher_title"].stringValue
    cur.creditScore = json["credit"].floatValue
    
    if let oddWeekArr = json["odd_week"].array {
        for owa in oddWeekArr {
            let a = Arrangement()
            a.weekDay = owa["week_day"].intValue
            a.startsAt = owa["start_from"].intValue
            a.endsAt = owa["end_at"].intValue
            a.classroom = owa["classroom"].stringValue
            cur.oddWeekArr.append(a)
        }
    }
    
    if let evenWeekArr = json["even_week"].array {
        for ewa in evenWeekArr {
            let a = Arrangement()
            a.weekDay = ewa["week_day"].intValue
            a.startsAt = ewa["start_from"].intValue
            a.endsAt = ewa["end_at"].intValue
            a.classroom = ewa["classroom"].stringValue
            cur.evenWeekArr.append(a)
        }
    }
    return cur
}
