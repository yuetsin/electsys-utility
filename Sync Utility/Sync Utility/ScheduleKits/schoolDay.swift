//
//  schoolDay.swift
//  Sync Utility
//
//  Created by yuxiqian on 2018/8/31.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Cocoa


class Day : NSObject {
    init(dayNum: Int) {
        self.dayNumber = dayNum
    }
    var dayNumber = 0
    var hasChildren = true
    var children: [Course] = []
}
    
let dayOfWeekName = ["星期一", "星期二", "星期三", "星期四", "星期五", "星期六", "星期日", "Unknown"]
