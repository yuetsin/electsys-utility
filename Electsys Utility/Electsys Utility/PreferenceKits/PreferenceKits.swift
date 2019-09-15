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

enum GPACalculationStrategy {
    case Normal_4_0
    case Improved_4_0_A
    case Improved_4_0_B
    case PKU_4_0
    case Canadian_4_3
    case USTC_4_3
    case SJTU_4_3
}
