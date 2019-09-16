//
//  PreferenceKits.swift
//  Electsys Utility
//
//  Created by 法好 on 2019/9/15.
//  Copyright © 2019 yuxiqian. All rights reserved.
//

import Foundation

class PreferenceKits {
    static func registerPreferenceKeys() {
        UserDefaults.standard.register(defaults: [
            "gpaStrategy" : GPACalculationStrategy.SJTU_4_3.rawValue,
            "courseDisplayStrategy": CourseNameDisplayStrategy.nameAndTeacher.rawValue,
            "hidePersonalInfo": true,
            "autoFillTokens": false,
            "autoFillUserName": "",
            "autoFillPassWord": ""
        ])
    }
    
    static var courseDisplayStrategy: CourseNameDisplayStrategy = .nameAndTeacher
    static var gpaStrategy: GPACalculationStrategy = .SJTU_4_3

    static var hidePersonalInfo: Bool = true
    static var autoFillTokens: Bool = false

    static var autoFillUserName: String = ""
    static var autoFillPassWord: String = ""

    static func readPreferences() {
        PreferenceKits.courseDisplayStrategy = CourseNameDisplayStrategy(rawValue: UserDefaults.standard.integer(forKey: "courseDisplayStrategy")) ?? .nameAndTeacher
        PreferenceKits.gpaStrategy = GPACalculationStrategy(rawValue: UserDefaults.standard.integer(forKey: "gpaStrategy")) ?? .SJTU_4_3
        PreferenceKits.hidePersonalInfo = UserDefaults.standard.bool(forKey: "hidePersonalInfo")
        PreferenceKits.autoFillTokens = UserDefaults.standard.bool(forKey: "autoFillTokens")
        if PreferenceKits.autoFillTokens {
            PreferenceKits.autoFillUserName = UserDefaults.standard.string(forKey: "autoFillUserName") ?? ""
            PreferenceKits.autoFillPassWord = UserDefaults.standard.string(forKey: "autoFillPassWord") ?? ""
        }
    }

    static func savePreferences() {
        UserDefaults.standard.set(PreferenceKits.courseDisplayStrategy.rawValue, forKey: "courseDisplayStrategy")
        UserDefaults.standard.set(PreferenceKits.gpaStrategy.rawValue, forKey: "gpaStrategy")
        UserDefaults.standard.set(PreferenceKits.hidePersonalInfo, forKey: "hidePersonalInfo")
        UserDefaults.standard.set(PreferenceKits.autoFillTokens, forKey: "autoFillTokens")
        if PreferenceKits.autoFillTokens {
            UserDefaults.standard.set(PreferenceKits.autoFillUserName, forKey: "autoFillUserName")
            UserDefaults.standard.set(PreferenceKits.autoFillPassWord, forKey: "autoFillPassWord")
        }
    }
}

enum CourseNameDisplayStrategy: Int {
    case nameAndTeacher = 0
    case codeNameAndTeacher = 1
    case nameOnly = 2
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
