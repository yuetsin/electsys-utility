//
//  AppUtils.swift
//  Sync Utility
//
//  Created by yuxiqian on 2018/8/29.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Foundation
import Cocoa

extension String {
    var count: Int {
        let string_NS = self as NSString
        return string_NS.length
    }
    
    func regExReplace(pattern: String, with: String,
                      options: NSRegularExpression.Options = []) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        return regex.stringByReplacingMatches(in: self, options: [],
                                              range: NSMakeRange(0, self.count),
                                              withTemplate: with)
    }
    
    // deprecated for parsing request url. doesn't work very well.
    // for example, using regular expression pattern: "(^|&)sid=([^&]*)(&|$)" to
    // parse the sid part.
    
    func regexGetSub(pattern: String, options: NSRegularExpression.Options = []) -> [String] {
        var subStr = [String]()
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        let matches = regex.matches(in: self, options: [], range: NSRange(self.startIndex...,in: self))
        for match in matches {
            subStr.append(contentsOf: [String(self[Range(match.range(at: 1), in: self)!]),String(self[Range(match.range(at: 2), in: self)!])])
        }
        return subStr
    }
}

func parseRequest(requestUrl: String, parseType: String, options: NSRegularExpression.Options = []) -> String {
    var toBeSplit = requestUrl.removingPercentEncoding ?? ""
    let splitKeyWord = ["?sid=", "&returl=", "&se="]
    var splitedRequest: [String] = []
    for item in splitKeyWord {
        let componentsOfString = toBeSplit.components(separatedBy: item)
        splitedRequest.append(componentsOfString[0].removingPercentEncoding!)
        if componentsOfString.count > 1 {
            toBeSplit = componentsOfString[1]
        } else {
            break
        }
    }
    splitedRequest.append(toBeSplit)
    switch parseType {
    case "sid":
        if splitedRequest.count > 1 {
            return splitedRequest[1]
        }
    case "returl":
        if splitedRequest.count > 2 {
            return splitedRequest[2]
        }
    case "se":
        if splitedRequest.count > 3 {
            return splitedRequest[3]
        }
    default:
        if splitedRequest.count > 1 {
            return splitedRequest[0]
        }
    }
    return ""
}


func sanitize(_ input: String?) -> String {
    if (input != nil) {
        return (input?.deleteOccur(remove: " ").deleteOccur(remove: "\t").deleteOccur(remove: "\n").deleteOccur(remove: "\r"))!
    } else {
        return "0"
    }
}

func clearBrackets(_ input: String) -> String {
    return input.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
}

func findIndexOfCourseByName (name: String, array: [Course]) -> Int {
    for index in 0...(array.count - 1) {
//        print("Attempted to compare \(name) and \(array[index].courseName)")
        if name == array[index].courseName {
            return index
        }
    }
    return -1
}

func generateArray(start: Int, end: Int, shift: ShiftWeekType) -> [Int] {
    var array: [Int] = []
    switch shift {
    case .Both:
        for i in start...end {
            array.append(i)
        }
        break
    case .EvenWeekOnly:
        var j = start
        while j <= end {
            if j % 2 == 0 {
                array.append(j)
            }
            j += 1
        }
        break
    case .OddWeekOnly:
        var k = start
        while k <= end {
            if k % 2 == 1 {
                array.append(k)
            }
            k += 1
        }
        break
    }
    return array
}

func getSharedArray(_ arrayA: [Int], _ arrayB: [Int]) -> [Int] {
    var shared: [Int] = []
    for element in arrayA {
        if arrayB.contains(element) {
            shared.append(element)
        }
    }
    return shared
}

func getCourseName(_ string: String) -> String {
    return String(string.prefix(string.positionOf(sub: "（", backwards: true)))
}

func getCourseRoom(_ string: String) -> String {
    return clearBrackets(("(\\[[^\\]]*\\])".r?.findFirst(in: string)?.group(at: 1)) ?? "未知")
}

func getStartWeek(_ string: String) -> Int {
    let weekIns = String(string.suffix(string.count - string.positionOf(sub: "（", backwards: true)))
//    print("getStartWeek: workaround \(weekIns)")
    return Int("(?<=（)[^-]+".r?.findFirst(in: weekIns)?.group(at: 0) ?? "0") ?? 0
}

func getEndWeek(_ string: String) -> Int {
    return Int("(?<=-)[^周）]+".r?.findFirst(in: string)?.group(at: 0) ?? "0") ?? 0
}

func checkIfWordyExpress(_ stringA: String, _ stringB: String) -> Bool {
//    print("判断可否合并。")
    // 在教务处给出的信息中，有时会出现这样的情况：
    // 分别声明了单周和双周，但是却完全没有任何不同。
    // 比如：
    // 算法原理（1-15周）[东上院202]单周
    // 算法原理（2-16周）[东上院202]双周
    // 此方法可以判断出这种情况是否出现。
    let courseNameA = getCourseName(stringA)
    let courseNameB = getCourseName(stringB)
//    print("课程名称：\(courseNameA) & \(courseNameB)")
    if sanitize(courseNameA) != sanitize(courseNameB) {
        return false
    }
    let roomA = getCourseRoom(stringA)
    let roomB = getCourseRoom(stringB)
//    print("教室：\(roomA) & \(roomB)")
    if roomA != roomB {
        return false
    }
    let startWeekA = getStartWeek(stringA)
    let startWeekB = getStartWeek(stringB)
    let endWeekA = getEndWeek(stringA)
    let endWeekB = getEndWeek(stringB)
//    print("周数：\(startWeekA) ~ \(endWeekA) & \(startWeekB) ~ \(endWeekB)")
    if abs(startWeekA - startWeekB) <= 1 && abs(endWeekA - endWeekB) <= 1 {
        return true
    } else {
        return false
    }
}

func combineWordyExpress(_ stringA: String, _ stringB: String) -> String {
    // 在教务处给出的信息中，有时会出现这样的情况：
    // 分别声明了单周和双周，但是却完全没有任何不同。
    // 比如：
    // 算法原理（1-15周）[东上院202]单周
    // 算法原理（2-16周）[东上院202]双周
    // 此方法可以将它们简化为：
    // 算法原理（1-16周）[东上院202]
    
    // 仅在保证二者可以合并
    // 即 checkIfWordyExpress 返回 true 时调用此方法。
    
    let courseName = getCourseName(stringA)
    let courseRoom = getCourseRoom(stringA)
    let startA = getStartWeek(stringA)
    let startB = getStartWeek(stringB)
    let endA = getEndWeek(stringA)
    let endB = getEndWeek(stringB)
    let start = min(startA, startB)
    let end = max(endA, endB)
    let result = "\(courseName)（\(start)-\(end)周）[\(courseRoom)]"
//    print("成功合并结果：\(result)")
    return result
}

func findCourseByIndex(_ i: Int, _ array: inout [Day]) -> Course {
    // count since 1 but not 0.
    if i <= 0 {
        return errorCourse
    }
    var index = i
    for day in 0...6 {
        index -= array[day].children.count
        if index <= 0 {
            index += array[day].children.count
            return array[day].children[index - 1]
        }
    }
    return errorCourse
}

func getExactTime(startAt: Int, duration: Int) -> String {
    let startTime = defaultLessonTime[startAt].getTimeString()
    let endTime = defaultLessonTime[startAt + duration - 1].getTimeString(passed: durationMinutesOfLesson)
    return "\(startTime) ~ \(endTime)"
}

extension String {
    func deleteOccur(remove: String) -> String {
        return self.replacingOccurrences(of: remove, with: "")
    }
}

//enum loginReturnCode {
//    case successLogin
//    case accountError
//    case argumentError
//    case networkError
//}

protocol requestHtmlDelegate: NSObjectProtocol {
    func validateLoginResult(htmlData: String) -> ()
    func syncExamInfo() -> ()
}

protocol inputHtmlDelegate: NSObjectProtocol {
    func checkDataInput(htmlData: String) -> ()
    func cancelDataInput() -> ()
}

protocol queryDelegate: NSObjectProtocol {
    func judgeResponse(htmlData: String) -> ()
}

protocol examQueryDelegate: NSObjectProtocol {
    func parseResponse(examData: String) -> ()
}

extension String {
    func positionOf(sub:String, backwards: Bool = false) -> Int {
        var position = -1
        if let range = range(of: sub, options: backwards ? .backwards : .literal ) {
            if !range.isEmpty {
                position = self.distance(from: startIndex, to: range.lowerBound)
            }
        }
        return position
    }
}

extension NSMenuItem {
    func indexIn(_ array: [NSMenuItem]) -> Int {
        var index = 0
        for item in array {
            if self == item {
//                print("定位到Course[\(index)]")
                return index
            }
            index += 1
        }
        return -1
    }
}

extension Date {
    
    func getWeekDay() -> Int {
        let calendar = NSCalendar.init(calendarIdentifier: .gregorian)
        let timeZone = NSTimeZone.init(name: "Asia/Shanghai")
        calendar?.timeZone = timeZone! as TimeZone
        let calendarUnit = NSCalendar.Unit.weekday
        let theComponents = calendar?.components(calendarUnit, from: self)
        if theComponents?.weekday == 1 {
            return 6
        }
        return ((theComponents?.weekday)! - 1)
    }
    
    
    func getStringExpression() -> String {
        let timeZone = TimeZone.init(identifier: "Asia/Shanghai")
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.string(from: self)
        return date.components(separatedBy: " ").first!
    }
}
