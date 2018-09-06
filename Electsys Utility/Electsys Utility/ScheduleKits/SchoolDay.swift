//
//  SchoolDay.swift
//  Sync Utility
//
//  Created by yuxiqian on 2018/8/31.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Cocoa


class Day : NSObject {
    init(_ dayNum: Int) {
        self.dayNumber = dayNum
    }
    var dayNumber = 0
//    var hasChildren = true
    var children: [Course] = []
}
    
let dayOfWeekName = ["Unknown", "周一", "周二", "周三", "周四", "周五", "周六", "周日"]

func getCourseCountOfDay(dayIndex: Int, array: [Course]) -> Int {
    var count: Int = 0
    for course in array {
        if course.courseDay == dayIndex {
            count += 1
        }
    }
    return count
}

func getAllCount(week: [Day]) -> Int {
    var count = 0
    for day in week {
        count += day.children.count
    }
    return count
}
