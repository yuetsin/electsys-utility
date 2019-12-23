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
let sdtLeftUrl = "http://electsys.sjtu.edu.cn/edu/student/sdtLeft.aspx"
let logOutUrl = "http://electsys.sjtu.edu.cn/edu/logOut.aspx"

class Login {
    
    var delegate: loginHelperDelegate?
    
    func attempt(userName: String, password: String, captchaWord: String, isLegacy: Bool = true) {
        if isLegacy {
            // Legacy stuff
            var responseHtml: String = ""
            Alamofire.request(loginUrl).response(completionHandler: { response in
                if response.response == nil {
                    self.delegate?.validateLoginResult(htmlData: "")
                    return
                }
                let responseItem = response.response!
                let jumpToUrl: String
                if responseItem.url != nil {
                    jumpToUrl = responseItem.url!.absoluteString
                } else {
                    self.delegate?.validateLoginResult(htmlData: "")
                    return
                }
                let sID = parseRequest(requestUrl: jumpToUrl, parseType: "sid")
                let returnUrl = parseRequest(requestUrl: jumpToUrl, parseType: "returl")
                let se = parseRequest(requestUrl: jumpToUrl, parseType: "se")
                ESLog.info("\nsID: \(sID) \nretUrl: \(returnUrl) \nse: \(se)")
                let postParams: Parameters = [
                    "sid": sID,
                    "returl": returnUrl,
                    "se": se,
                    "v": "",
                    "user": userName,
                    "pass": password,
                    "captcha": captchaWord
                ]
                Alamofire.request(postUrl, method: .post, parameters: postParams, encoding: URLEncoding.httpBody).responseData(completionHandler: { response in
                    responseHtml = String(data: response.data!, encoding: .utf8)!
                    if (responseHtml.contains("上海交通大学教学信息服务网－学生服务平台")) {
                        // successfully goes in!
                            Alamofire.request(contentUrl).responseData(completionHandler: { response in
                                let realOutput = String(data: response.data!, encoding: .utf8)!
        //                        print(realOutput)
                                self.delegate?.validateLoginResult(htmlData: realOutput)
                            })
                    } else {
                        self.delegate?.validateLoginResult(htmlData: responseHtml)
                    }
    //                NSLog("reponseHtml successfully obtained.")
                })
            })
        } else {
            // Brand new stuff
            
        }
    }
    
    func updateCaptcha() {
        Alamofire.request(captchaUrl).responseData { response in
            let captchaImageObject = NSImage(data: response.data!)
            if captchaImageObject != nil {
                self.delegate?.setCaptchaImage(image: captchaImageObject!)
            } else {
                self.delegate?.setCaptchaImage(image: NSImage(imageLiteralResourceName: "NSStopProgressTemplate"))
                self.delegate?.failedToLoadCaptcha()
            }
        }
    }
    
    func logOut() {
        Alamofire.request(logOutUrl)
    }
}

protocol loginHelperDelegate: NSObjectProtocol {
    func validateLoginResult(htmlData: String) -> ()
//    func syncExamInfo() -> ()
    func setCaptchaImage(image: NSImage) -> ()
    func failedToLoadCaptcha() -> ()
    func forceResetAccount() -> ()
}
