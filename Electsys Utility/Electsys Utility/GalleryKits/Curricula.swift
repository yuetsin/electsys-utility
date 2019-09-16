//
//  Curricula.swift
//  Electsys Utility
//
//  Created by yuxiqian on 2018/9/6.
//  Copyright © 2018 yuxiqian. All rights reserved.
//  
//  ScheduleKits/Course.swift 用于处理「课程表内」相关的课程信息。
//  GalleryKits/Curricula.swift 用于处理教室信息之中的信息。

import Foundation

class Curricula {
//    var codeName: String = ""
    var name: String = ""
    var holderSchool: String = ""
    var teacherName: String = ""
    var teacherTitle: String = ""
    var identifier: String = ""
    var creditScore: Float = 0.0
    var year: Year = .Y_2019_2020
    var targetGrade: Int = 0
    var term: Term = .Spring
    var studentNumber: Int = 0
//    var maximumNumber: Int = 0
    var startWeek: Int = 0
    var endWeek: Int = 0
    var oddWeekArr: [Arrangement] = []
    var evenWeekArr: [Arrangement] = []
    var notes: String = ""
    
    func getRelatedClassroom() -> [String] {
        var classrooms: [String] = []

        for i in oddWeekArr {
            if !classrooms.contains(i.classroom) {
                classrooms.append(i.classroom)
            }
        }
        for i in evenWeekArr {
            if !classrooms.contains(i.classroom) {
                classrooms.append(i.classroom)
            }
        }
        return classrooms
    }
    
    func isContinuous() -> Bool {
        if oddWeekArr.count != evenWeekArr.count {
            return false
        }
        for i in 0..<oddWeekArr.count {
            if oddWeekArr[i] != evenWeekArr[i] {
                return false
            }
        }
        return true
    }
}

class Arrangement {

    var weekDay: Int = 0
// 星期数。约定使用 1 ～ 7 分别代表周一到周日。

    var startsAt = 0
// 开始节数

    var endsAt = 0
// 结束节数

    var classroom = ""
// 授课教室
    
    static func != (left: Arrangement, right: Arrangement) -> Bool {
        return !(left.weekDay == right.weekDay) &&
        (left.startsAt == right.startsAt) &&
        (left.endsAt == right.endsAt) &&
        (left.classroom == right.classroom)
    }
}

enum Year: Int {
    case Y_2019_2020 = 2019
    case Y_2018_2019 = 2018
    case Y_2017_2018 = 2017
    case Y_2016_2017 = 2016
    case Y_2015_2016 = 2015
    case Y_2014_2015 = 2014
    case Y_2013_2014 = 2013
    case Y_2012_2013 = 2012
    case Y_2011_2012 = 2011
    case Y_2010_2011 = 2010
    case __BAD_YEAR = 0
}

enum Term: Int {
    case Autumn = 1
    case Spring = 2
    case Summer = 3
}


func ConvertToYear(_ string: String) -> Year {
    var startYear = 2010
    while startYear < 2018 {
        if string.contains(String(startYear)) && string.contains(String(startYear + 1)) {
            return Year(rawValue: startYear)!
        }
        startYear += 1
    }
    return .Y_2018_2019
}

func ConvertToString(_ year: Year) -> String {
    return "\(year.rawValue)-\(year.rawValue + 1)"
}

func ConvertToTerm(_ string: String) -> Term {
    if string.contains("1") {
        return .Autumn
    } else if string.contains("3") {
        return .Summer
    } else {
        return .Spring
    }
}


func rawValueToInt(_ string: String) -> Int {
    if string == "秋季学期" {
        return 1
    } else if string == "春季学期" {
        return 2
    } else {
        return 3
    }
}

