//
//  RegularExpression.swift
//  courseSync
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
    
    func regexGetSub(pattern: String, options: NSRegularExpression.Options = []) -> [String] {
        var subStr = [String]()
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        let matches = regex.matches(in: self, options: [], range: NSRange(self.startIndex...,in: self))
        for match in matches {
            subStr.append(contentsOf: [String(self[Range(match.range(at: 1), in: self)!]),String(self[Range(match.range(at: 2), in: self)!])])
        }
        return subStr
    }
    
    // deprecated for parsing request url. doesn't work very well.
    // for example, using regular expression pattern: "(^|&)sid=([^&]*)(&|$)" to
    // parse the sid part.

    func regExGetFirstOccur(pattern: String, options: NSRegularExpression.Options = []) -> String {
        var subStr = [String]()
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        let matches = regex.matches(in: self, options: [], range: NSRange(self.startIndex...,in: self))
        for match in matches {
            subStr.append(contentsOf: [String(self[Range(match.range(at: 1), in: self)!]),String(self[Range(match.range(at: 2), in: self)!])])
        }
        if subStr.count > 0 {
            return subStr[0]
        } else {
            return ""
        }
    }
}

func parseRequest(requestUrl: String, parseType: String, options: NSRegularExpression.Options = []) -> String {
    var toBeSplit = requestUrl.removingPercentEncoding ?? ""
//    NSLog("现在的 toBeSplit: \(toBeSplit)")
    let splitKeyWord = ["?sid=", "&returl=", "&se="]
    var splitedRequest: [String] = []
    for item in splitKeyWord {
        splitedRequest.append((toBeSplit.components(separatedBy: item)[0].removingPercentEncoding)!)
        toBeSplit = toBeSplit.components(separatedBy: item)[1]
    }
    splitedRequest.append(toBeSplit)
    switch parseType {
    case "sid":
        return splitedRequest[1]
    case "returl":
        return splitedRequest[2]
    case "se":
        if splitedRequest.count < 4 {
            return ""
        } else {
            return splitedRequest[3]
        }
    default:
        return splitedRequest[0]
    }
}
