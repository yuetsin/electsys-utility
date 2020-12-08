//
//  LoginKits.swift
//  Electsys Utility
//
//  Created by 法好 on 2019/9/12.
//  Copyright © 2019 yuxiqian. All rights reserved.
//

import Cocoa
import Kanna
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
            
            if response.data != nil {
                let doc = String(data: response.data!, encoding: .utf8)
                ESLog.info("### got login html page ###")
                ESLog.info(doc ?? "<< error >>")
                ESLog.info("### got login html page over ###")
                
                if doc != nil {
                    let tokens = doc!.components(separatedBy: "'captcha?uuid=")
                    if tokens.count > 1 {
                        let latter_tokens = tokens.last!.components(separatedBy: "&t='")
                        if latter_tokens.count > 1 {
                            CaptchaHelper.uuid = latter_tokens.first!
                            CaptchaHelper.t = String(Date().timeIntervalSince1970)
                            
                            ESLog.info("get captcha uuid \(CaptchaHelper.uuid ?? "<< error >>")")
                            ESLog.info("set captcha timestamp \(CaptchaHelper.t ?? "<< error >>")")
                        }
                    }
                }
            }
            
            let redirectURL = response.response?.url?.absoluteString
            if redirectURL == nil {
                ESLog.warning("failed to get 302 redirect url")
                handler?()
                return
            }
            ESLog.info("get 302 redirect url")
            
            LoginHelper.sID = parseRequest(requestUrl: redirectURL!, parseType: "sid")
            ESLog.info("got sID \(LoginHelper.sID ?? "<nil>")")
            
            LoginHelper.client = parseRequest(requestUrl: redirectURL!, parseType: "client")
            ESLog.info("got client \(LoginHelper.client ?? "<nil>")")
            
            LoginHelper.returnUrl = parseRequest(requestUrl: redirectURL!, parseType: "returl")
            ESLog.info("got returnUrl \(LoginHelper.returnUrl ?? "<nil>")")
            
            LoginHelper.se = parseRequest(requestUrl: redirectURL!, parseType: "se")
            ESLog.info("got se \(LoginHelper.se ?? "<nil>")")
            
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
                ESLog.info("good redirectURL: \(redirectURL!)")
                LoginHelper.lastLoginTimeStamp = redirectURL?.replacingOccurrences(of: "https://i.sjtu.edu.cn/xtgl/index_initMenu.html?jsdm=xs&_t=", with: "")
                ESLog.info("login timestamp: \(LoginHelper.lastLoginTimeStamp ?? "<nil>")")
                handler(true)
            } else {
                ESLog.warning("bad redirectURL: \(redirectURL!). might not login")
                handler(false)
            }
        }
    }
    
    static func requestCaptcha(_ handler: @escaping (NSImage) -> ()) {
        Alamofire.request(captchaUrl).responseData { response in
            ESLog.info("get captcha response with \(response.error?.localizedDescription ?? "no error")")
            let captchaImageObject = NSImage(data: response.data!)
            if captchaImageObject != nil {
                ESLog.info("retrieved captcha image")
                handler(captchaImageObject!)
            } else {
                ESLog.error("failed to construct captcha image")
            }
        }
    }
    
    static func attemptLogin(username: String, password: String, captcha: String, handler: @escaping (_ success: Bool) -> ()) {
        LoginHelper.initRedirectUrl(handler: {
            self.performLogin(username, password, captcha, handler)
        })
    }
    
    fileprivate static func performLogin(_ username: String, _ password: String, _ captcha: String, _ handler: @escaping (_ success: Bool) -> ()) {
        if (sID == nil || LoginHelper.client == nil || returnUrl == nil || se == nil) {
            ESLog.error("insufficient login certs")
            handler(false)
            return
        }
        
        let postParams: Parameters = [
            "sid": LoginHelper.sID!,
            "returl": LoginHelper.returnUrl!,
            "se": LoginHelper.se!,
            "v": "",
            "uuid": "15cf4fb3-21a9-45a0-9dda-fbf1795065cb",
            "client": LoginHelper.client!,
            "user": username,
            "pass": password,
            "captcha": captcha
        ]
        
        Alamofire.request(LoginConst.postUrl, method: .post, parameters: postParams).response { response in
            let redirectURL = response.response?.url?.absoluteString
//            let realResponse = String(data: response.data!, encoding: .utf8)
            ESLog.info("login redirect to: \(redirectURL ?? "nil")")
            if redirectURL == nil || redirectURL!.contains("&err=1") {
                ESLog.error("login post failure")
                LoginHelper.lastLoginUserName = "{null}"
                LoginHelper.logOut()
                handler(false)
            } else {
                
                ESLog.info("login complete! check validation...")
                
                LoginHelper.checkLoginAvailability({ result in
                    if result {
                        ESLog.info("good login session")
                        LoginHelper.lastLoginUserName = username
                        handler(true)
                    } else {
                        ESLog.warning("bad login session")
                        LoginHelper.lastLoginUserName = "{null}"
                        LoginHelper.logOut()
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
                ESLog.info("remove cookie \(cookie.name)")
                cstorage.deleteCookie(cookie)
            }
        }
        
        if let cookies = cstorage.cookies(for: URL(string: "https://jaccount.sjtu.edu.cn")!) {
            for cookie in cookies {
                ESLog.info("remove cookie \(cookie.name)")
                cstorage.deleteCookie(cookie)
            }
        }
    }
}
