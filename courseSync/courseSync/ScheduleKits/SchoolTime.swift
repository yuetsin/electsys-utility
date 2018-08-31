//
//  SchoolTime.swift
//  Sync Utility
//
//  Created by yuxiqian on 2018/8/30.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Foundation

class Time {
    var hour: Int
    var minute: Int
    init (Hour: Int, Minute: Int) {
        self.hour = Hour
        self.minute = Minute
    }
    init (_ timeString: String) {
        let formatter = timeString.split(separator: ":")
        if formatter.count == 2 {
            let hourNum = Int(formatter[0]) ?? -1
            let minuteNum = Int(formatter[1]) ?? -1
            if hourNum >= 0 && hourNum <= 23 {
                if minuteNum >= 0 && minuteNum <= 59 {
                    self.hour = hourNum
                    self.minute = minuteNum
                    return
                }
            }
        }
        self.hour = -1
        self.minute = -1
    }
}

class SchoolDay : NSObject {
    init(dayNum: Int) {
        self.dayNumber = dayNum
    }
    var dayNumber = 0
    var hasChildren = true
    var children: [Course] = []
}

let defaultLessonTime: [Time] = [
    Time("8:00"), Time("8:55"), Time("10:00"), Time("10:55"),
    Time("12:00"), Time("12:55"), Time("14:00"), Time("14:55"),
    Time("16:00"), Time("16:55"), Time("18:00"), Time("18:55"),
    Time("20:00"), Time("20:55")
]

let dayOfWeekName = ["星期一", "星期二", "星期三", "星期四", "星期五", "星期六", "星期日", "Unknown"]
