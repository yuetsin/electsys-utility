//
//  ViewController.swift
//  Sync Utility
//
//  Created by yuxiqian on 2018/8/29.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Alamofire
import Cocoa
import Foundation
import Kanna

class jAccountViewController: NSViewController, WebLoginDelegate {

    func validateLoginResult(htmlData: String) {
        // reset
    }

    func forceResetAccount() {
        // reset
    }

//    var windowController: NSWindowController?

    var htmlDelegate: readInHTMLDelegate?
    var UIDelegate: UIManagerDelegate?

    override func viewWillAppear() {
        checkLoginStatus()
    }

    override func viewDidLoad() {
        setAccessibilityLabel()
        successImage.image = NSImage(named: "NSStatusNone")
        loginStateText.stringValue = "您尚未登入。"
    }

    func setAccessibilityLabel() {
        accessNewElectsys.setAccessibilityLabel("访问新版教学信息服务网")
        accessLegacyElectsys.setAccessibilityLabel("访问旧版教学信息服务网")
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

//    var requestDelegate: requestHtmlDelegate?
//    var inputDelegate: inputHtmlDelegate?

    @IBOutlet var accessNewElectsys: NSButton!
    @IBOutlet var accessLegacyElectsys: NSButton!
//    @IBOutlet var userNameField: NSTextField!
//    @IBOutlet var passwordField: NSSecureTextField!
//    @IBOutlet var captchaTextField: NSTextField!
//    @IBOutlet var captchaImage: NSImageView!
//    @IBOutlet var loginButton: NSButton!
//    @IBOutlet var refreshCaptchaButton: NSButton!
//    @IBOutlet var resetButton: NSButton!
////    @IBOutlet weak var manualOpenButton: NSButton!
//    @IBOutlet var loadingIcon: NSProgressIndicator!
////    @IBOutlet weak var expandButton: NSButton!
////    @IBOutlet weak var operationSelector: NSPopUpButton!
////    @IBOutlet weak var checkHistoryButton: NSButton!
    @IBOutlet var successImage: NSImageView!
    @IBOutlet var loginStateText: NSTextField!
//    @IBOutlet weak var switchAccountButton: NSButton!
    
    lazy var embedWebVC: WebLoginViewController = {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        return storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("WebLoginViewController"))
            as! WebLoginViewController
    }()
    
    lazy var cookieParserVC: CookieParserViewController = {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        return storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("CookieParserViewController"))
            as! CookieParserViewController
    }()
    
    @IBAction func loginViaWebPage(_ sender: NSButton) {
        if #available(OSX 10.13, *) {
            embedWebVC.delegate = self
            presentAsSheet(embedWebVC)
        } else {
            showErrorMessage(errorMsg: "当前运行的系统版本低于 macOS 10.13。囿于 WKWebView API 的限制，无法使用 Web 登录功能。")
        }
    }
    
    
    @IBAction func loginViaCookies(_ sender: NSButton) {
        cookieParserVC.delegate = self
        presentAsSheet(cookieParserVC)
    }
    
    func callbackWeb(_ success: Bool) {
        dismiss(embedWebVC)
        checkLoginStatus()
    }
    
    func callbackCookie(_ success: Bool) {
        dismiss(cookieParserVC)
        checkLoginStatus()
    }

    func checkLoginStatus() {
        successImage.image = NSImage(named: "NSStatusPartiallyAvailable")
        loginStateText.stringValue = "正在检查登入状态…"
        LoginHelper.checkLoginAvailability({ status in
            if status {
                self.successImage.image = NSImage(named: "NSStatusAvailable")
                self.loginStateText.stringValue = "您已经成功登入。"
                self.UIDelegate?.unlockIcon()
            } else {
                if LoginHelper.lastLoginUserName != "{null}" {
                    self.UIDelegate?.lockIcon()
                    self.successImage.image = NSImage(named: "NSStatusUnavailable")
                    self.loginStateText.stringValue = "登入身份已过期。"
                    self.UIDelegate?.lockIcon()
                    if self.view.window == nil {
                        LoginHelper.lastLoginUserName = "{null}"
                    }
                    LoginHelper.lastLoginUserName = "{null}"
                } else {
                    self.successImage.image = NSImage(named: "NSStatusNone")
                    self.loginStateText.stringValue = "您尚未登入。"
                    self.UIDelegate?.lockIcon()
                }
            }
        })
    }

    func showErrorMessage(errorMsg: String) {
        let errorAlert: NSAlert = NSAlert()
        errorAlert.messageText = "出错啦"
        errorAlert.informativeText = errorMsg
        errorAlert.addButton(withTitle: "嗯")
        errorAlert.alertStyle = NSAlert.Style.critical
        errorAlert.beginSheetModal(for: view.window!, completionHandler: nil)
        ESLog.error("internal error occured. message: ", errorMsg)
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

    @IBAction func goToElectsysNew(_ sender: NSButton) {
        if let url = URL(string: "https://i.sjtu.edu.cn/"), NSWorkspace.shared.open(url) {
            // successfully opened
            ESLog.info("goes to electsys (modern version)")
        }
    }

    @IBAction func goToElectsysLegacy(_ sender: NSButton) {
        if let url = URL(string: "http://electsys.sjtu.edu.cn"), NSWorkspace.shared.open(url) {
            // successfully opened
            ESLog.info("goes to electsys (legacy version)")
        }
    }
}
