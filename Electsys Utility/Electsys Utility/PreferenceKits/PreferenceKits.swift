//
//  PreferenceKits.swift
//  Electsys Utility
//
//  Created by 法好 on 2019/9/15.
//  Copyright © 2019 yuxiqian. All rights reserved.
//

import Foundation

class PreferenceKits {
    static var courseDisplayStrategy: CourseNameDisplayStrategy = .nameAndTeacher
    static var gpaStrategy: GPACalculationStrategy = .SJTU_4_3
    
    static var hidePersonalInfo: Bool = true
    static var autoFillTokens: Bool = false
    
    static var autoFillUserName: String = ""
    static var autoFillPassWord: String = ""
}

enum CourseNameDisplayStrategy {
    case nameAndTeacher
    case codeNameAndTeacher
    case nameOnly
}

enum GPACalculationStrategy: Int {
    case Normal_4_0 = 0
    case Improved_4_0_A = 1
    case Improved_4_0_B = 2
    case PKU_4_0 = 3
    case Canadian_4_3 = 4
    case USTC_4_3 = 5
    case SJTU_4_3 = 6
}
