//
//  AppUtils.swift
//  Sync Utility
//
//  Created by yuxiqian on 2018/8/29.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Foundation

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


func sanitize(_ input: String) -> String {
    return input.replacingOccurrences(of: " ", with: "")
}

func clearBrackets(_ input: String) -> String {
    return input.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
}

func findIndexOfCourseByName (name: String, array: [Course]) -> Int {
    for index in 0...(array.count - 1) {
//        print("Attempted to compare \(name) and \(array[index].courseName)")
        if name.contains(array[index].courseName) {
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
            if j % 2 == 1 {
                array.append(j)
            }
            j += 1
        }
        break
    case .OddWeekOnly:
        var k = start
        while k <= end {
            if k % 2 == 0 {
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

enum loginReturnCode {
    case successLogin
    case accountError
    case argumentError
    case networkError
}

protocol requestHtmlDelegate: NSObjectProtocol {
    func validateLoginResult(htmlData: String) -> ()
}

protocol inputHtmlDelegate: NSObjectProtocol {
    func checkDataInput(htmlData: String) -> ()
    func cancelDataInput() -> ()
}

