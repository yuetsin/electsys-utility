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
    var courseName: String?
    var courseCode: String?
    var location: String?
    var teacher: String?
    var startDate: Date?
    var endDate: Date?
    var campus: String?
    var originalTime: String?
    
    func getTime() -> String {
        if startDate == nil || endDate == nil {
            ESLog.error("invalid NGExam date entry")
            return "未知"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        return "\(formatter.string(from: startDate!)) 至 \(formatter.string(from: endDate!))"
    }
}
