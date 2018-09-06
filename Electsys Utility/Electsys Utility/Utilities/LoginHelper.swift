//
//  LoginHelper.swift
//  Sync Utility
//
//  Created by yuxiqian on 2018/8/29.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Foundation
import Alamofire

let electSysUrl = "http://electsys.sjtu.edu.cn/"
let loginUrl = "http://electsys.sjtu.edu.cn/edu/login.aspx"
let targetUrl = "http://electsys.sjtu.edu.cn/edu/student/sdtMain.aspx"
let contentUrl = "http://electsys.sjtu.edu.cn/edu/newsboard/newsinside.aspx"
let captchaUrl = "https://jaccount.sjtu.edu.cn/jaccount/captcha"
let postUrl = "https://jaccount.sjtu.edu.cn/jaccount/ulogin"

class Login {
    
    var delegate: requestHtmlDelegate?
    
    func attempt(userName: String, password: String, captchaWord: String, isLegacy: Bool = true) {
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
//                "v": "",
    //          empty parameter v is no longer necessary.
                "user": userName,
                "pass": password,
                "captcha": captchaWord
            ]

            Alamofire.request(postUrl, method: .post, parameters: postParams, encoding: URLEncoding.httpBody).responseData(completionHandler: { response in
                responseHtml = String(data: response.data!, encoding: .utf8)!
                if (responseHtml.contains("上海交通大学教学信息服务网－学生服务平台")) {
                    // successfully goes in!
                    if isLegacy {
                        Alamofire.request(contentUrl).responseData(completionHandler: { response in
                            let realOutput = String(data: response.data!, encoding: .utf8)!
    //                        print(realOutput)
                            self.delegate?.validateLoginResult(htmlData: realOutput)
                        })
                    } else {
                        self.delegate?.syncExamInfo()
                    }
                } else {
                    self.delegate?.validateLoginResult(htmlData: responseHtml)
                }
//                NSLog("reponseHtml successfully obtained.")
            })
        })
    }
}
