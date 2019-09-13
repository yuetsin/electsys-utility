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
    
    static var sID: String?
    static var client: String?
    static var returnUrl: String?
    static var se: String?
    
    static var lastLoginUserName: String = "{null}"
    static var lastLoginTimeStamp: String = ""
    
    static func initRedirectUrl(handler: (() -> ())? = nil) {
        Alamofire.request(LoginConst.loginUrl, method: .get).response { response in
            let redirectURL = response.response?.url?.absoluteString
            if redirectURL == nil {
                NSLog("failed to get 302 redirect url")
                return
            }
            
            LoginHelper.sID = parseRequest(requestUrl: redirectURL!, parseType: "sid")
            LoginHelper.client = parseRequest(requestUrl: redirectURL!, parseType: "client")
            LoginHelper.returnUrl = parseRequest(requestUrl: redirectURL!, parseType: "returl")
            LoginHelper.se = parseRequest(requestUrl: redirectURL!, parseType: "se")
            
            NSLog("\nsID: \(LoginHelper.sID ?? "nil") \nclient: \(LoginHelper.client ?? "nil")\nretUrl: \(LoginHelper.returnUrl ?? "nil") \nse: \(LoginHelper.se ?? "nil")")
        }
    }
    
    static func checkLoginAvailability(_ handler: @escaping (Bool) -> ()) {
        Alamofire.request(LoginConst.mainPageUrl, method: .get).response { response in
//            let responseStr = String(data: response.data!, encoding: .utf8)
            let redirectURL = response.response?.url?.absoluteString
            if redirectURL == nil {
                handler(false)
            } else if redirectURL == LoginConst.mainPageUrl {
                NSLog("good redirectURL: \(redirectURL!)")
                handler(true)
            } else {
                NSLog("bad redirectURL: \(redirectURL!)")
                handler(false)
            }
        }
    }
    
    static func requestCaptcha(_ handler: @escaping (NSImage) -> ()) {
        Alamofire.request(captchaUrl).responseData { response in
            let captchaImageObject = NSImage(data: response.data!)
            if captchaImageObject != nil {
                handler(captchaImageObject!)
            }
        }
    }
    
    static func attemptLogin(username: String, password: String, captcha: String, handler: @escaping (_ success: Bool) -> ()) {
        if sID == nil || LoginHelper.client == nil || LoginHelper.returnUrl == nil || se == nil {
            LoginHelper.initRedirectUrl(handler: {
                self.performLogin(username, password, captcha, handler)
            })
        } else {
            performLogin(username, password, captcha, handler)
        }
    }
    
    fileprivate static func performLogin(_ username: String, _ password: String, _ captcha: String, _ handler: @escaping (_ success: Bool) -> ()) {
        assert(!(sID == nil || LoginHelper.client == nil || returnUrl == nil || se == nil))
        
        let postParams: Parameters = [
            "sid": LoginHelper.sID!,
            "returl": LoginHelper.returnUrl!,
            "se": LoginHelper.se!,
            /* 'v': "" */
            "client": LoginHelper.client!,
            "user": username,
            "pass": password,
            "captcha": captcha
        ]
        
        Alamofire.request(LoginConst.postUrl, method: .post, parameters: postParams).response { response in
            let redirectURL = response.response?.url?.absoluteString
            NSLog("login redirect to: \(redirectURL ?? "nil")")
            if redirectURL == nil || redirectURL!.contains("&err=1") {
                NSLog("login post failure")
                handler(false)
            } else {
                let responseStr = String(data: response.data!, encoding: .utf8)
                NSLog("login complete!")
                LoginHelper.lastLoginUserName = username
                handler(true)
            }
        }
    }
    
    static func logOut() {

            let getParams: Parameters = [
                "t": Date().milliStamp,
                "login_type": ""
            ]
            LoginHelper.lastLoginUserName = "{null}"
            Alamofire.request(LoginConst.logOutUrl, method: .get, parameters: getParams).response { _ in
                LoginHelper.removeCookie()
                LoginHelper.sID = nil
                LoginHelper.client = nil
                LoginHelper.returnUrl = nil
                LoginHelper.se = nil
                LoginHelper.initRedirectUrl()
            }
    }
    
    static func removeCookie() {
        let cookieStorage = HTTPCookieStorage.shared
        cookieStorage.removeCookies(since: Date(timeIntervalSinceNow: -1000.0))
    }
}
