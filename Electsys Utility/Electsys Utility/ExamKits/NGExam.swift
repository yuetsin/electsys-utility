//
//  NGExam.swift
//  Electsys Utility
//
//  Created by 法好 on 2019/9/15.
//  Copyright © 2019 yuxiqian. All rights reserved.
//

import Foundation

struct NGExam {
    var name: String?
    var location: String?
    var teacher: String?
    var startDate: Date?
    var endDate: Date?
    
    func generatePrompt() -> String {
        return "\(teacher ?? "某老师")「\(name ?? "某节课程")」@ \(location ?? "某地")"
    }
}
