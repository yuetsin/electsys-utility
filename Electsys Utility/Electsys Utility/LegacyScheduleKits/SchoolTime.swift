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
    
    func getTimeString(passed: Int = 0) -> String {
        var pastHour = hour
        var pastMinute = minute + passed
        if pastMinute >= 60 {
            pastHour += 1
            pastMinute -= 60
        }
        return String(format: "%d:%02d", arguments: [pastHour, pastMinute])
    }
    
    func getTime(passed: Int = 0) -> Time {
        var pastHour = hour
        var pastMinute = minute + passed
        if pastMinute >= 60 {
            pastHour += 1
            pastMinute -= 60
        }
        return Time(Hour: pastHour, Minute: pastMinute)
    }
}


let durationMinutesOfLesson = 45
// 一节课 = 四十五分钟

let secondsInDay: Double = 86400
// 一天 = 86400秒

let secondsInEighteenWeeks: Double = 10886400
// 正常学期与小学期间隔 18 周。折合 10886400 秒。

let defaultLessonTime: [Time] = [Time("0:00"),
    Time("8:00"), Time("8:55"), Time("10:00"), Time("10:55"),
    Time("12:00"), Time("12:55"), Time("14:00"), Time("14:55"),
    Time("16:00"), Time("16:55"), Time("18:00"), Time("18:55"),
    Time("20:00"), Time("20:55"), Time("0:00"), Time("0:00"), Time("0:00"), Time("0:00")
]

