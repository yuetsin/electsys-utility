//
//  Teacher.swift
//  Electsys Utility
//
//  Created by yuxiqian on 2018/9/6.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Alamofire
import Kanna

class Teacher {
    // She's my favorite teacher.
    var employeeID: String = "1024800048"
    // 某些老师的工号 ID 里会包含字母…所以不可以用整型存储。
    
    var name: String = "何琼"
    var gender: Gender = .Female
    var graduateSchool: String = "上海外国语大学"
    var rankScore: Float = 100.0
    
    func requestRankScore() {
        let requestUrl = teacherEvaluate + "gh=\(self.employeeID)&xm=\(self.name)"
    }
}

func findTeacherById(_ id: String, _ teachers: inout [Teacher]) -> Int {
    var index = 0
    for t in teachers {
        if t.employeeID == id {
            return index
        }
        index += 1
    }
    return -1
}

enum Gender {
    case Male
    case Female
}
