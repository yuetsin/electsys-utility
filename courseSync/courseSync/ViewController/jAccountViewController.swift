//
//  ViewController.swift
//  courseSync
//
//  Created by yuxiqian on 2018/8/29.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Foundation
import Cocoa
import Alamofire

class jAccountViewController: NSViewController, requestHtmlDelegate, inputHtmlDelegate {
    
//    var requestDelegate: requestHtmlDelegate?
//    var inputDelegate: inputHtmlDelegate?
    
    @IBOutlet weak var userNameField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    @IBOutlet weak var captchaTextField: NSTextField!
    @IBOutlet weak var captchaImage: NSImageView!
    @IBOutlet weak var loginButton: NSButton!
    @IBOutlet weak var refreshCaptchaButton: NSButton!
    @IBOutlet weak var resetButton: NSButton!
    @IBOutlet weak var manualOpenButton: NSButton!
    
    @IBAction func loginButtonClicked(_ sender: NSButton) {
        let accountParams = [self.userNameField.stringValue, self.passwordField.stringValue, self.captchaTextField.stringValue]
        disableUI()
        let loginSession = Login()
        loginSession.delegate = self
        DispatchQueue.global().async {
            loginSession.attempt(userName: accountParams[0], password: accountParams[1], captchaWord: accountParams[2])
        }
    }
    
    @IBAction func updateCaptcha(_ sender: NSButton) {
        self.captchaTextField.stringValue = ""
        Alamofire.request(captchaUrl).responseData { response in
            let captchaImageObject = NSImage(data: response.data!)
            if captchaImageObject != nil {
                self.captchaImage.image = captchaImageObject
            } else {
//                self.captchaImage.image = 
                self.showErrorMessage(errorMsg: "未能成功加载验证码图片。\n\n检查你的网络连接。")
            }
        }
    }
    
    @IBAction func resetInput(_ sender: NSButton) {
        userNameField.stringValue = ""
        passwordField.stringValue = ""
        captchaTextField.stringValue = ""
        updateCaptcha(refreshCaptchaButton)
        removeCookie()
    }

    func removeCookie() {
        let cookieStorage = HTTPCookieStorage.shared
        if let cookies = cookieStorage.cookies(for: URL(string: electSysUrl)!) {
            for cookie in cookies {
                cookieStorage.deleteCookie(cookie)
            }
        }
    }
    
    @IBAction func manualLoadHTML(_ sender: NSButton) {
        disableUI()
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let manualOpenViewController = storyboard.instantiateController(withIdentifier: "htmlGetViewController") as! htmlGetViewController
        manualOpenViewController.delegate = self
        let manualOpenWindowController = storyboard.instantiateController(withIdentifier: "Manually Get HTML Window Controller") as! NSWindowController
        manualOpenWindowController.contentViewController = manualOpenViewController
        manualOpenWindowController.showWindow(sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        removeCookie()
        updateCaptcha(refreshCaptchaButton)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func validateLoginResult(htmlData: String) {
        print(htmlData)
        if (htmlData.contains("上海交通大学教学信息服务网－学生服务平台") ||
            htmlData.contains("本学期课程详细情况")) {
//        success!
            startDataResolve(html: htmlData)
        } else if (htmlData.contains("请勿频繁登陆本网站，以免服务器过载。请30秒后再登陆。")) {
            showErrorMessage(errorMsg: "登录失败。\n\n登录过于频繁，请至少等待 30 秒后再次尝试。")
            resumeUI()
        }
        else if (htmlData.contains("上海交通大学统一身份认证")) {
            showErrorMessage(errorMsg: "登录失败。\n\n用户名、密码和验证码中有至少一项不正确。")
            resumeUI()
        } else if (!htmlData.isEmpty) {
            showErrorMessage(errorMsg: "登录失败。\n\n请求的参数不正确。")
            resumeUI()
        } else {
            showErrorMessage(errorMsg: "登录失败。\n\n检查你的网络连接。")
            resumeUI()
        }
    }
    
    func checkDataInput(htmlData: String) {
//        NSLog(htmlData)
        if (htmlData.contains("上海交通大学教学信息服务网－学生服务平台") ||
            htmlData.contains("本学期课程详细情况")) {
            startDataResolve(html: htmlData)
        } else {
            showErrorMessage(errorMsg: "置入 HTML 文件失败。\n\n获取的数据格式不正确。")
            resumeUI()
        }
    }
    
    
    func cancelDataInput() {
        resumeUI()
    }
    
    func startDataResolve(html: String) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let resolveWindowController = storyboard.instantiateController(withIdentifier: "Resolve Window Controller") as! NSWindowController
        if let resolveWindow = resolveWindowController.window {
            let resolveViewController = storyboard.instantiateController(withIdentifier: "Resolve View Controller") as! ResolveViewController
            resolveViewController.htmlDoc = html
            resolveWindow.contentViewController = resolveViewController
            resolveWindowController.showWindow(self)
        }
        self.view.window?.close()
    }
    

    func disableUI() {
        userNameField.isEnabled = false
        passwordField.isEnabled = false
        captchaTextField.isEnabled = false
        loginButton.isEnabled = false
        resetButton.isEnabled = false
        refreshCaptchaButton.isEnabled = false
        manualOpenButton.isEnabled = false
        captchaImage.isEnabled = false
    }
    
    func resumeUI() {
        userNameField.isEnabled = true
        passwordField.isEnabled = true
        captchaTextField.isEnabled = true
        loginButton.isEnabled = true
        resetButton.isEnabled = true
        refreshCaptchaButton.isEnabled = true
        manualOpenButton.isEnabled = true
        captchaImage.isEnabled = true
        updateCaptcha(refreshCaptchaButton)
    }

    func showErrorMessage(errorMsg: String) {
        let errorAlert: NSAlert = NSAlert()
        errorAlert.messageText = errorMsg
        errorAlert.alertStyle = NSAlert.Style.critical
        errorAlert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
}

