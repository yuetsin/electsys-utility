//
//  LoginHelper.swift
//  courseSync
//
//  Created by yuxiqian on 2018/8/29.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Foundation
import Alamofire

let loginUrl = "http://electsys.sjtu.edu.cn/edu/login.aspx"
let targetUrl = "http://electsys.sjtu.edu.cn/edu/student/sdtMain.aspx"
let captchaUrl = "https://jaccount.sjtu.edu.cn/jaccount/captcha"
let postUrl = "https://jaccount.sjtu.edu.cn/jaccount/ulogin"

class Login {
    var delegate: requestHtmlDelegate?
    func attempt(userName: String, password: String, captchaWord: String) {
        var responseHtml: String = ""
        Alamofire.request(loginUrl).response(completionHandler: { response in
            if response.response == nil {
                self.delegate?.validateLoginResult(htmlData: responseHtml)
                return
            }
            let responseItem = response.response!
            let jumpToUrl: String
            if responseItem.url != nil {
                jumpToUrl = responseItem.url!.absoluteString
            } else {
                return
            }
            let sID = parseRequest(requestUrl: jumpToUrl, parseType: "sid")
            let returnUrl = parseRequest(requestUrl: jumpToUrl, parseType: "returl")
            let se = parseRequest(requestUrl: jumpToUrl, parseType: "se")
            NSLog("\nsID: \(sID) \nretUrl: \(returnUrl) \nse: \(se)")
            let postParams: Parameters = [
                "sid": sID,
                "returl": returnUrl,
                "se": se,
    //            "v": "",
    //          empty parameter v is no longer necessary.
                "user": userName,
                "pass": password,
                "captcha": captchaWord
            ]

            Alamofire.request(postUrl, method: .post, parameters: postParams, encoding: URLEncoding.default).responseString(completionHandler: { response in
                responseHtml = String(data: response.data!, encoding: String.Encoding.utf8)!
                NSLog("reponseHtml successfully obtained.")
                self.delegate?.validateLoginResult(htmlData: responseHtml)
            })
        })
    }
}
