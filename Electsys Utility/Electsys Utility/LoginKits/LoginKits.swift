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
    static var lastLoginTimeStamp: String?
    
    static func initRedirectUrl(handler: (() -> ())? = nil) {
        Alamofire.request(LoginConst.loginUrl, method: .get).response { response in
            let redirectURL = response.response?.url?.absoluteString
            if redirectURL == nil {
                NSLog("failed to get 302 redirect url")
                handler?()
                return
            }
            
            LoginHelper.sID = parseRequest(requestUrl: redirectURL!, parseType: "sid")
            LoginHelper.client = parseRequest(requestUrl: redirectURL!, parseType: "client")
            LoginHelper.returnUrl = parseRequest(requestUrl: redirectURL!, parseType: "returl")
            LoginHelper.se = parseRequest(requestUrl: redirectURL!, parseType: "se")
            
            NSLog("\nsID: \(LoginHelper.sID ?? "nil") \nclient: \(LoginHelper.client ?? "nil")\nretUrl: \(LoginHelper.returnUrl ?? "nil") \nse: \(LoginHelper.se ?? "nil")")
            handler?()
        }
    }
    
    static func checkLoginAvailability(_ handler: @escaping (Bool) -> ()) {
        Alamofire.request(LoginConst.loginUrl, method: .get).response { response in
//            let responseStr = String(data: response.data!, encoding: .utf8)
            let redirectURL = response.response?.url?.absoluteString
            if redirectURL == nil {
                handler(false)
            } else if redirectURL?.contains(LoginConst.mainPageUrl) ?? false {
                NSLog("good redirectURL: \(redirectURL!)")
                LoginHelper.lastLoginTimeStamp = redirectURL?.replacingOccurrences(of: "http://i.sjtu.edu.cn/xtgl/index_initMenu.html?jsdm=xs&_t=", with: "")
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
        LoginHelper.initRedirectUrl(handler: {
            self.performLogin(username, password, captcha, handler)
        })
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
            let responseStr = String(data: response.data!, encoding: .utf8)
            NSLog("login redirect to: \(redirectURL ?? "nil")")
            if redirectURL == nil || redirectURL!.contains("&err=1") {
                NSLog("login post failure")
                LoginHelper.lastLoginUserName = "{null}"
                LoginHelper.removeCookie()
                handler(false)
            } else {
                
                NSLog("login complete! check validation...")
                
                LoginHelper.checkLoginAvailability({ result in
                    if result {
                        NSLog("good login session")
                        LoginHelper.lastLoginUserName = username
                        handler(true)
                    } else {
                        NSLog("bad login session")
                        LoginHelper.lastLoginUserName = "{null}"
                        LoginHelper.removeCookie()
                        handler(false)
                    }
                })
            }
        }
    }
    
    static func logOut(handler: (() -> ())? = nil) {
            let getParams: Parameters = [
                "t": LoginHelper.lastLoginTimeStamp ?? Date().milliStamp,
                "login_type": ""
            ]
            LoginHelper.lastLoginUserName = "{null}"
        Alamofire.request(LoginConst.logOutUrl, method: .get, parameters: getParams).response { _ in
            LoginHelper.removeCookie()
            handler?()
        }
    }
    
    static func removeCookie() {
        let cstorage = HTTPCookieStorage.shared
        if let cookies = cstorage.cookies(for: URL(string: "http://i.sjtu.edu.cn")!) {
            for cookie in cookies {
                cstorage.deleteCookie(cookie)
            }
        }
        
        if let cookies = cstorage.cookies(for: URL(string: "https://jaccount.sjtu.edu.cn")!) {
            for cookie in cookies {
                cstorage.deleteCookie(cookie)
            }
        }
    }
}
