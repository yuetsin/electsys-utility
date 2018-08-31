//
//  schoolTerm.swift
//  Sync Utility
//
//  Created by yuxiqian on 2018/8/30.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Foundation

class Term {
    let daysOfWeek = 7
    let lessonsOfDay = 14
    var weeks: [Week] = []
    init(isSummerTerm: Bool = false) {
        if isSummerTerm {
            for _ in 1...4 {
                weeks.append(Week())
            }
        } else {
            for _ in 1...22 {
                weeks.append(Week())
            }
        }
    }
}

