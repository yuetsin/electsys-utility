//
//  NGCourse.swift
//  Electsys Utility
//
//  Created by 法好 on 2019/9/15.
//  Copyright © 2019 yuxiqian. All rights reserved.
//

import Foundation

struct NGCourse {
    
    var courseIdentifier: String = ""
    
    var courseCode: String = ""

    var courseName: String = ""
    var courseTeacher: [String] = []
    var courseTeacherTitle: [String] = []
    
    var courseRoom: String = ""
    var courseDay: Int = -1

    var courseScore: Float = 0.0
    var dayStartsAt: Int = 0
    var dayEndsAt: Int = 0
    
    var weekStartsAt: Int = 0
    var weekEndsAt: Int = 0
    var shiftWeek: ShiftWeekType = .Both
    
    var notes: String = ""
    
    func getExtraIdentifier() -> String {
        var identifier = self.courseName + "，"
        switch self.shiftWeek {
        case .EvenWeekOnly:
            identifier += "双周"
            break
        case .OddWeekOnly:
            identifier += "单周"
            break
        default:
            break
        }
        identifier += dayOfWeekName[self.courseDay]
        return identifier
    }
    
    func generateCourseName() -> String {
        if PreferenceKits.courseDisplayStrategy == .nameOnly {
            return "\(courseName)"
        } else if PreferenceKits.courseDisplayStrategy == .nameAndTeacher {
            return "\(courseName)，\(courseTeacher.joined(separator: "、"))"
        } else if PreferenceKits.courseDisplayStrategy == .codeNameAndTeacher {
            return "\(courseCode) - \(courseName)，\(courseTeacher.joined(separator: "、"))"
        }
        return ""
    }
    
    func getTime() -> String {
        var timeString = ""
        if self.weekStartsAt == self.weekEndsAt {
            timeString += "\(self.weekStartsAt) 周"
        } else if self.weekEndsAt - self.weekStartsAt == 1 {
            timeString += "\(self.weekStartsAt)、\(self.weekEndsAt) 周"
        } else {
            timeString += "\(self.weekStartsAt) ~ \(self.weekEndsAt) 周"
        }
        switch self.shiftWeek {
        case .EvenWeekOnly:
            timeString += "双周"
            break
        case .OddWeekOnly:
            timeString += "单周"
            break
        default:
            break
        }
        timeString += dayOfWeekName[self.courseDay]
        timeString += " \(self.dayStartsAt) ~ \(self.dayEndsAt) 节，"
        timeString += getExactTime(startAt: self.dayStartsAt, duration: self.dayEndsAt - self.dayStartsAt + 1)
        return timeString
    }
}
