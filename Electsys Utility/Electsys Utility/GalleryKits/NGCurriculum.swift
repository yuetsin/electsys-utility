//
//  NGCurricula.swift
//  Electsys Utility
//
//  Created by 法好 on 2019/9/17.
//  Copyright © 2019 yuxiqian. All rights reserved.
//

import Foundation

class NGArrangements: Equatable {
    static func == (lhs: NGArrangements, rhs: NGArrangements) -> Bool {
        return lhs.weeks == rhs.weeks && lhs.weekDay == rhs.weekDay
            && lhs.sessions == rhs.sessions && lhs.campus == rhs.campus
            && lhs.classroom == rhs.classroom
    }

    internal init(weeks: [Int], weekDay: Int, sessions: [Int], campus: String, classroom: String) {
        self.weeks = weeks
        self.weekDay = weekDay
        self.sessions = sessions
        self.campus = campus
        self.classroom = classroom
    }

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

class NGCurriculum: Equatable {
    static func == (lhs: NGCurriculum, rhs: NGCurriculum) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    internal init(identifier: String, code: String, holderSchool: String, name: String, year: Int, term: Int, targetGrade: Int, teacher: [String], credit: Double, arrangements: [NGArrangements], studentNumber: Int, notes: String) {
        self.identifier = identifier
        self.code = code
        self.holderSchool = holderSchool
        self.name = name
        self.year = year
        self.term = term
        self.targetGrade = targetGrade
        self.teacher = teacher
        self.credit = credit
        self.arrangements = arrangements
        self.studentNumber = studentNumber
        self.notes = notes
    }

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
