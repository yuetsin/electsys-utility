//
//  LoginKits.swift
//  Electsys Utility
//
//  Created by 法好 on 2019/9/12.
//  Copyright © 2019 yuxiqian. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON

class LoginHelper {
    
    init() {
        initRedirectUrl()
    }
    
    var sID: String?
    var client: String?
    var returnUrl: String?
    var se: String?
    
    fileprivate func initRedirectUrl(handler: (() -> ())? = nil) {
        Alamofire.request(LoginConst.loginUrl, method: .get).response { response in
            let redirectURL = response.response?.url?.absoluteString
            if redirectURL == nil {
                NSLog("failed to get 302 redirect url")
                return
            }
            
            self.sID = parseRequest(requestUrl: redirectURL!, parseType: "sid")
            self.client = parseRequest(requestUrl: redirectURL!, parseType: "client")
            self.returnUrl = parseRequest(requestUrl: redirectURL!, parseType: "returl")
            self.se = parseRequest(requestUrl: redirectURL!, parseType: "se")
            
            NSLog("\nsID: \(self.sID ?? "nil") \nclient: \(self.client ?? "nil")\nretUrl: \(self.returnUrl ?? "nil") \nse: \(self.se ?? "nil")")
        }
    }
    
    func requestCaptcha(_ handler: @escaping (NSImage) -> ()) {
        Alamofire.request(captchaUrl).responseData { response in
            let captchaImageObject = NSImage(data: response.data!)
            if captchaImageObject != nil {
                handler(captchaImageObject!)
            }
        }
    }
    
    func attemptLogin(username: String, password: String, captcha: String, handler: @escaping (_ success: Bool) -> ()) {
        if sID == nil || client == nil || returnUrl == nil || se == nil {
            initRedirectUrl(handler: {
                self.performLogin(username, password, captcha, handler)
            })
        } else {
            performLogin(username, password, captcha, handler)
        }
    }
    
    fileprivate func performLogin(_ username: String, _ password: String, _ captcha: String, _ handler: @escaping (_ success: Bool) -> ()) {
        assert(!(sID == nil || client == nil || returnUrl == nil || se == nil))
        
        let postParams: Parameters = [
            "sid": sID!,
            "returl": returnUrl!,
            "se": se!,
            /* 'v': "" */
            "client": client!,
            "user": username,
            "pass": password,
            "captcha": captcha
        ]
        
        Alamofire.request(LoginConst.postUrl, method: .post, parameters: postParams).response { response in
            let redirectURL = response.response?.url?.absoluteString
            if redirectURL == nil || redirectURL!.contains("&err=1") {
                NSLog("login post failure")
                handler(false)
            } else {
                NSLog("login success!")
                handler(true)
            }
        }
    }
    
    func logOut() {
        Alamofire.request(LoginConst.logOutUrl, method: .post)
    }
    
    func removeCookie() {
        logOut()
        let cookieStorage = HTTPCookieStorage.shared
        cookieStorage.removeCookies(since: Date(timeIntervalSinceNow: -1000.0))
    }
}
