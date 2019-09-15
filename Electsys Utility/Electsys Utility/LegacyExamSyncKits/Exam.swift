//
//  Exam.swift
//  Electsys Utility
//
//  Created by yuxiqian on 2018/9/6.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Foundation

class Exam {
    var name: String?
    var location: String?
    var teacher: String?
    var startDate: Date?
    var endDate: Date?
    
    func generatePrompt() -> String {
        return "\(teacher ?? "某老师")「\(name ?? "某节课程")」@ \(location ?? "某地")"
    }
}
