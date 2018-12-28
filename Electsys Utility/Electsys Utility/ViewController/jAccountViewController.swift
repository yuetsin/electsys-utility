//
//  ViewController.swift
//  Sync Utility
//
//  Created by yuxiqian on 2018/8/29.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Foundation
import Cocoa
import Kanna
import Alamofire

class jAccountViewController: NSViewController, loginHelperDelegate {

//    var windowController: NSWindowController?
    
    var loginSession: Login?
    var htmlDelegate: readInHTMLDelegate?
    var UIDelegate: UIManagerDelegate?
    
    override func viewDidLoad() {
//        super.viewDidLoad()
        loginSession = Login()
        loginSession?.delegate = self
        loadingIcon.startAnimation(self)
        removeCookie()
        updateCaptcha(refreshCaptchaButton)
//        openRequestPanel()
    }
    
    override func viewWillDisappear() {
        htmlDelegate = nil
        UIDelegate = nil

    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
//    var requestDelegate: requestHtmlDelegate?
//    var inputDelegate: inputHtmlDelegate?
    
    @IBOutlet weak var userNameField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    @IBOutlet weak var captchaTextField: NSTextField!
    @IBOutlet weak var captchaImage: NSImageView!
    @IBOutlet weak var loginButton: NSButton!
    @IBOutlet weak var refreshCaptchaButton: NSButton!
    @IBOutlet weak var resetButton: NSButton!
//    @IBOutlet weak var manualOpenButton: NSButton!
    @IBOutlet weak var loadingIcon: NSProgressIndicator!
//    @IBOutlet weak var expandButton: NSButton!
//    @IBOutlet weak var operationSelector: NSPopUpButton!
//    @IBOutlet weak var checkHistoryButton: NSButton!
    
    @IBAction func loginButtonClicked(_ sender: NSButton) {
        if self.userNameField.stringValue == "" ||
            self.passwordField.stringValue == "" ||
            self.captchaTextField.stringValue == "" {
            showErrorMessage(errorMsg: "请完整填写所有信息。")
            return
        }
        let accountParams = [self.userNameField.stringValue, self.passwordField.stringValue, self.captchaTextField.stringValue]
        disableUI()
        self.loginSession = Login()
        self.loginSession?.delegate = self
        
//        if self.operationSelector.selectedItem!.title == "同步课程表到系统日历" {
            DispatchQueue.global().async {
                self.loginSession?.attempt(userName: accountParams[0], password: accountParams[1], captchaWord: accountParams[2])
            }
//        } else if self.operationSelector.selectedItem!.title == "同步考试安排到系统日历" {
//            DispatchQueue.global().async {
//                self.loginSession?.attempt(userName: accountParams[0], password: accountParams[1], captchaWord: accountParams[2], isLegacy: false)
//            }
//        }
    }
    
    @IBAction func updateCaptcha(_ sender: NSButton) {
        self.captchaTextField.stringValue = ""
        loginSession?.updateCaptcha()
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
    
    func setCaptchaImage(image: NSImage) {
        self.captchaImage.image = image
    }


    
//    @IBAction func manualLoadHTML(_ sender: NSButton) {
//        disableUI()
//        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
//        windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Manually Get HTML Window Controller")) as? NSWindowController
//        if let htmlWindow = windowController?.window {
//            let htmlViewController = htmlWindow.contentViewController as! htmlGetViewController
//            htmlViewController.delegate = self
//            self.view.window?.beginSheet(htmlWindow, completionHandler: nil)
//        }
//    }

    
    func validateLoginResult(htmlData: String) {
//        print(htmlData)
        if (htmlData.contains("上海交通大学教学信息服务网－学生服务平台") ||
            htmlData.contains("本学期课程详细情况")) {
//        success!
            self.htmlDelegate?.htmlDoc = htmlData
            self.UIDelegate?.unlockIcon()
            self.UIDelegate?.switchToPage(index: 4)
        } else if (htmlData.contains("请勿频繁登陆本网站，以免服务器过载。请30秒后再登陆。")) {
            showErrorMessage(errorMsg: "登录失败。\n请求过于频繁，请至少等待 30 秒后再次尝试。")
            self.UIDelegate?.lockIcon()
            resumeUI()
        }
        else if (htmlData.contains("上海交通大学统一身份认证")) {
            showErrorMessage(errorMsg: "登录失败。\n用户名、密码和验证码中有至少一项不正确。")
            self.UIDelegate?.lockIcon()
            resumeUI()
        } else if (!htmlData.isEmpty) {
            showErrorMessage(errorMsg: "登录失败。\n访问被拒绝。请重启应用后再次尝试。")
            self.UIDelegate?.lockIcon()
            resumeUI()
        } else {
            showErrorMessage(errorMsg: "登录失败。\n检查你的网络连接。")
            self.UIDelegate?.lockIcon()
            resumeUI()
        }
    }
    
    func checkDataInput(htmlData: String) {
//        NSLog(htmlData)
        if (htmlData.contains("上海交通大学教学信息服务网－学生服务平台") ||
            htmlData.contains("本学期课程详细情况") || htmlData.contains("节\\星期")) {
//            startDataResolve(html: htmlData)
        } else {
            showErrorMessage(errorMsg: "置入 HTML 文件失败。\n获取的数据格式不正确。")
            resumeUI()
        }
    }
    
    
    func cancelDataInput() {
        resumeUI()
    }
//
//    func startDataResolve(html: String) {
//        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
//        windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Resolve Window Controller")) as? NSWindowController
//        if let resolveWindow = windowController?.window {
//            let resolveViewController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Resolve View Controller")) as! ResolveViewController
//            resolveViewController.htmlDoc = html
//            resolveWindow.contentViewController = resolveViewController
//            windowController?.showWindow(self)
//            self.view.window?.orderOut(self)
//        }
//    }
//
//    func syncExamInfo() {
//        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
//        windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Sync Exam Window Controller")) as? NSWindowController
//        windowController?.showWindow(self)
//        self.view.window?.orderOut(self)
//    }
    

    func disableUI() {
        userNameField.isEnabled = false
        passwordField.isEnabled = false
        captchaTextField.isEnabled = false
        loginButton.isEnabled = false
        resetButton.isEnabled = false
        refreshCaptchaButton.isEnabled = false
//        manualOpenButton.isEnabled = false
        captchaImage.isEnabled = false
//        operationSelector.isEnabled = false
//        checkHistoryButton.isEnabled = false
        loadingIcon.isHidden = false
    }
    
    func resumeUI() {
        userNameField.isEnabled = true
        passwordField.isEnabled = true
        captchaTextField.isEnabled = true
        loginButton.isEnabled = true
        resetButton.isEnabled = true
        refreshCaptchaButton.isEnabled = true
        captchaImage.isEnabled = true
//        operationSelector.isEnabled = true
//        checkHistoryButton.isEnabled = true
        loadingIcon.isHidden = true
        updateCaptcha(refreshCaptchaButton)
//        if operationSelector.selectedItem!.title == "同步课程表到系统日历" {
//            manualOpenButton.isEnabled = true
//        }
    }

    func showErrorMessage(errorMsg: String) {
        let errorAlert: NSAlert = NSAlert()
        errorAlert.messageText = "出错啦"
        errorAlert.informativeText = errorMsg
        errorAlert.addButton(withTitle: "嗯")
        errorAlert.alertStyle = NSAlert.Style.critical
        errorAlert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
    
    func failedToLoadCaptcha() {
        showErrorMessage(errorMsg: "获取验证码时发生错误。\n请检查您的网络连接。")
    }
    
//    @IBAction func onExpand(_ sender: NSButton) {
//        var frame: NSRect = (self.view.window?.frame)!
//        if sender.state == .on {
//            frame.size = NSSize(width: 260, height: 318)
//        } else {
//            frame.size = NSSize(width: 260, height: 230)
//        }
//        self.view.window?.setFrame(frame, display: true, animate: true)
//    }
    
//
//    @IBAction func operationSelectorPopped(_ sender: NSPopUpButton) {
//        if sender.selectedItem!.title == "同步课程表到系统日历" {
//            self.manualOpenButton.isEnabled = true
//        } else {
//            self.manualOpenButton.isEnabled = false
//        }
//    }
    
//    @IBAction func checkHistoryData(_ sender: NSButton) {
//        // do something crazy
//        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
//        windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("FullDataWindowController")) as? FullDataWindowController
//        windowController?.showWindow(self)
//    }
}


