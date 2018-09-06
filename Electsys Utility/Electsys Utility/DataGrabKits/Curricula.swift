//
//  Curricula.swift
//  Electsys Utility
//
//  Created by yuxiqian on 2018/9/6.
//  Copyright © 2018 yuxiqian. All rights reserved.
//  
//  ScheduleKits/Course.swift 用于处理「课程表内」相关的课程信息。
//  Utility/Curricula.swift 用于处理不与课程表相关的其他信息。

import Foundation

class Curricula {
    var codeName: String = ""
    var name: String = ""
    var teacherName: String = ""
    var identifier: String = ""
    var notes: String = ""
    var year: Year = .Y_2017_2018
    var term: Term = .Spring
    var studentNumber: Int = 0
    var maximumNumber: Int = 0
    
    func getSelectRatio() -> Float {
        if self.maximumNumber != 0 {
            return Float(self.studentNumber) / Float(self.maximumNumber)
        } else {
            return 1.0
        }
    }
    
    func printToConsole() {
        print("Name: \(codeName) - \(name)")
        print("Teacher: \(teacherName)")
    }
}


enum Year: Int {
    case Y_2017_2018 = 2017
    case Y_2016_2017 = 2016
    case Y_2015_2016 = 2015
    case Y_2014_2015 = 2014
    case Y_2013_2014 = 2013
    case Y_2012_2013 = 2012
    case Y_2011_2012 = 2011
    case Y_2010_2011 = 2010
}

enum Term: Int {
    case Autumn = 1
    case Spring = 2
    case Summer = 3
}


func ConvertToYear(_ string: String) -> Year {
    var startYear = 2010
    while startYear < 2017 {
        if string.contains(String(startYear)) && string.contains(String(startYear + 1)) {
            return Year(rawValue: startYear)!
        }
        startYear += 1
    }
    return .Y_2017_2018
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
