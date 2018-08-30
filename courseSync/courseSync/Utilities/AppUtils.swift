//
//  AppUtils.swift
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
