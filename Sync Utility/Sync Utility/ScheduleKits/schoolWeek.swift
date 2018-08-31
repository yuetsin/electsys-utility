//
//  schoolWeek.swift
//  Sync Utility
//
//  Created by yuxiqian on 2018/8/31.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Foundation

class Week: NSObject {
    var weekNum: Int = 0
    var days: [Day] = []
    override init() {
        for day in 0...6 {
            days.append(Day(dayNum: day))
        }
    }
}
