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



func attemptLogin() -> Bool {
    Alamofire.request(loginUrl).responseString(completionHandler: {response in
        if let obtainData = response.data, let utf8Text = String(data: obtainData, encoding: .utf8) {
            var retUrl = utf8Text.regexGetSub(pattern: "returl\"\\s+value=\"(.*?)\">")
            var sid = utf8Text.regexGetSub(pattern: "sid\"\\s+value=\"(.*?)\">")
            var se = utf8Text.regexGetSub(pattern: "se\"\\s+value=\"(.*?)\">")
        }
    })

    return true
}
