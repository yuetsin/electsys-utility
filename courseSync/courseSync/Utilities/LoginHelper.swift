//
//  LoginHelper.swift
//  courseSync
//
//  Created by yuxiqian on 2018/8/29.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Foundation
import Alamofire
import Kanna

let loginUrl = "http://electsys.sjtu.edu.cn/edu/login.aspx"
let targetUrl = "http://electsys.sjtu.edu.cn/edu/student/sdtMain.aspx"
let captchaUrl = "https://jaccount.sjtu.edu.cn/jaccount/captcha"
let postUrl = "https://jaccount.sjtu.edu.cn/jaccount/ulogin"



func attemptLogin(userName: String, password: String, captchaWord: String) -> Bool {
    var responseHtml: String = ""
    Alamofire.request(loginUrl).response(completionHandler: {response in
        let jumpToUrl = response.response!.url?.absoluteString
        let sID = parseRequest(requestUrl: jumpToUrl!, parseType: "sid")
        let returnUrl = parseRequest(requestUrl: jumpToUrl!, parseType: "returl")
        let se = parseRequest(requestUrl: jumpToUrl!, parseType: "se")
//        NSLog("sID: \(sID), retUrl: \(returnUrl), se: \(se)")
        let postParams: Parameters = [
            "sid": sID,
            "returl": returnUrl,
            "se": se,
//            "v": "",
            "user": userName,
            "pass": password,
            "captcha": captchaWord
        ]

        Alamofire.request(postUrl, method: .post, parameters: postParams, encoding: URLEncoding.default).responseString(completionHandler: { response in
            responseHtml = String(data: response.data!, encoding: String.Encoding.utf8)!
            NSLog(responseHtml)
        })
    })
    return loginResultChecker(result: responseHtml)
}

func loginResultChecker(result: String) -> Bool {
        if result.contains("上海交通大学统一身份认证") {
            return false
        } else {
            return true
        }
}
