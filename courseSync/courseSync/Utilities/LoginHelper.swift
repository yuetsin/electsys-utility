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
    Alamofire.request(loginUrl).response(completionHandler: {response in
        let jumpUrl = response.response?.url?.absoluteString
        let returnUrl = jumpUrl!.regExGetFirstOccur(pattern: "(^|&)returl=([^&]*)(&|$)")
        let sID = jumpUrl!.regExGetFirstOccur(pattern: "(^|&)sid=([^&]*)(&|$)")
        let se = jumpUrl!.regExGetFirstOccur(pattern: "(^|&)se=([^&]*)(&|$)")
        let postParams: Parameters = [
            "sid": sID,
            "returl": returnUrl,
            "se": se,
            "v": "",
            "user": userName,
            "pass": password,
            "captcha": captchaWord
        ]
        Alamofire.request(postUrl, method: .post, parameters: postParams, encoding: URLEncoding.default).responseString(completionHandler: { response in
        NSLog(String(data: response.data!, encoding: String.Encoding.utf8)!)
        })
    })
    return true
}
