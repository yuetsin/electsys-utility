//
//  Course.swift
//  Sync Utility
//
//  Created by yuxiqian on 2018/8/30.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Foundation

class Course : NSObject {
    let hasChildren = false
    var courseIdentifier: String = ""
    var isSummerVacation: Bool = false
    var courseName: String = ""
    var courseTeacher: String = ""
    var courseRoom: String = ""
    var courseDay: Int = -1

    var courseScore: Float = 0.0
    var dayStartsAt: Int = 0
    var courseDuration: Int = 0
    var weekStartsAt: Int = 0
    var weekEndsAt: Int = 0
    var shiftWeek: ShiftWeekType = .Both
    
    var isFollower = false
    
    init (_ CourseName: String, identifier: String, CourseScore: Float) {
        self.courseName = sanitize(CourseName)
        self.courseIdentifier = sanitize(identifier)
        self.courseScore = CourseScore
    }
    
    func setClassroom(classroom: String) {
        self.courseRoom = sanitize(classroom)
    }
    
    func setTeacherName(teacher: String) {
        self.courseTeacher = sanitize(teacher)
    }
    
    func setTimetable(startsAt: Int, duration: Int) {
        self.dayStartsAt = startsAt
        self.courseDuration = duration
    }
    
    func setWeekDuration(start: Int, end: Int) {
        self.weekStartsAt = start
        self.weekEndsAt = end
    }
    
    func judgeIfConflicts(_ another: Course, summerMode: Bool = false) -> Bool {
        // 判断冲突与否，需要看现在加入的是否是小学期的课程。
        // 同一张课表里，就算不在同一周出现，也不会占有相同的时间（除非是在同一格中同时开始）
        // （否则课表无法成形）
        // 但是小学期和主课表完全分开不属于同一张课表
        // 因此需要判断的内容更多。
        // 故而需要参数 summerMode
        if summerMode {
            if (self.courseDay != another.courseDay) {
                return false
            }
            
            if self.weekEndsAt < another.weekStartsAt {
                return false
            }
            
            if self.weekStartsAt > another.weekEndsAt {
                return false
            }
            
            if self.shiftWeek == .EvenWeekOnly && another.shiftWeek == .OddWeekOnly {
                return false
            }
            
            if self.shiftWeek == .OddWeekOnly && another.shiftWeek == .EvenWeekOnly {
                return false
            }
        }
        
        let selfWeek = generateArray(start: self.weekStartsAt,
                                     end: weekEndsAt,
                                     shift: self.shiftWeek)
        let anotherWeek = generateArray(start: another.weekStartsAt,
                                        end: another.weekEndsAt,
                                        shift: another.shiftWeek)
        let shared = getSharedArray(selfWeek, anotherWeek)
        
        if shared.isEmpty {
            return false
        }
        if self.dayStartsAt + self.courseDuration - 1 < another.dayStartsAt {
            return false
        }
        
        return true
    }
    
    func judgeIfDuplicates(in week: [Day]) -> Bool {
        var count = 0
        for day in week {
            for item in day.children {
                if self.courseName == item.courseName {
                    count += 1
                }
            }
        }
        if count > 1 {
            return true
        }
        return false
    }
    
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
        timeString += " \(self.dayStartsAt) ~ \(self.dayStartsAt + self.courseDuration - 1) 节，"
        timeString += getExactTime(startAt: self.dayStartsAt, duration: self.courseDuration)
        return timeString
    }
}

let errorCourse = Course("未知", identifier: "未知", CourseScore: 0.0)

enum ShiftWeekType {
    case OddWeekOnly
    case EvenWeekOnly
    case Both
}

func getAllCourseInDay(_ index: Int, _ array: [Course]) -> [Course] {
    var resultArray: [Course] = []
    for course in array {
        if course.courseDay == index {
            resultArray.append(course)
        }
    }
    return resultArray
}


