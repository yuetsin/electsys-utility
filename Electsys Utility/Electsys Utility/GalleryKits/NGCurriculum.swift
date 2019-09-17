//
//  NGCurricula.swift
//  Electsys Utility
//
//  Created by 法好 on 2019/9/17.
//  Copyright © 2019 yuxiqian. All rights reserved.
//

import Foundation

struct NGArrangements {
    var weeks: [Int]
    var weekDay: Int
    var sessions: [Int]
    var campus: String
    var classroom: String
    
    func getWeeksInterpreter() -> String {
        var weeksStr: [String] = []
        for week in weeks {
            weeksStr.append(String(week))
        }
        return "第 " + weeksStr.joined(separator: "、") + " 周"
    }
    
    func getSessionsInterpreter() -> String {
        var sessionsStr: [String] = []
        for session in sessions {
            sessionsStr.append(String(session))
        }
        return "第 " + sessionsStr.joined(separator: "、") + " 节"
    }
}

struct NGCurriculum {
    var identifier: String
    var code: String
    var holderSchool: String
    var name: String
    var year: Int
    var term: Int
    var targetGrade: Int
    var teacher: [String]
    var credit: Double
    var arrangements: [NGArrangements]
    var studentNumber: Int
    var notes: String
    func getRelated() -> [StringPair] {
        var classRoomsLiteral: [StringPair] = []
        for arr in arrangements {
            if !classRoomsLiteral.contains(StringPair(strA: arr.classroom, strB: arr.campus)) {
                classRoomsLiteral.append(StringPair(strA: arr.classroom, strB: arr.campus))
            }
        }
        return classRoomsLiteral
    }
}

struct StringPair: Equatable {
    var strA: String
    var strB: String
}
