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
    var courseWeek: [Bool] = []
    var courseScore: Float = 0.0
    var courseStartsAt: Int = 0
    var courseDuration: Int = 0
    
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
    
    func setTimetable(startsAt: Int, duration: Int, arrangement: [Bool]) -> Bool {
        self.courseStartsAt = startsAt
        self.courseDuration = duration
        if arrangement.count == 16 && !isSummerVacation {
            self.courseWeek = arrangement
            return true
        } else if (arrangement.count == 4 && isSummerVacation) {
            self.courseWeek = arrangement
            return true
        }
        return false
    }
}
