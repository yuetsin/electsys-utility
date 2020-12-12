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
        accessNewElectsys.setAccessibilityLabel("访问教学信息服务网")
//        accessLegacyElectsys.setAccessibilityLabel("访问旧版教学信息服务网")
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

//    var requestDelegate: requestHtmlDelegate?
//    var inputDelegate: inputHtmlDelegate?

    @IBOutlet var accessNewElectsys: NSButton!
//    @IBOutlet var accessLegacyElectsys: NSButton!
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
    @IBOutlet var exportCookieButton: NSButton!

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
            showErrorMessage(errorMsg: "当前运行的系统版本低于 macOS 10.13。\n囿于 WKWebView API 的限制，无法使用 Web 登录功能。")
        }
    }

    @IBAction func exportCookieButton(_ sender: NSButton) {
        guard let cookies = Alamofire.HTTPCookieStorage.shared.cookies else {
            showErrorMessage(errorMsg: "没有可用于导出的 HTTP Cookie Storage。")
            return
        }
        var cookieArray = [[HTTPCookiePropertyKey: Any]]()
        for cookie in cookies {
            cookieArray.append(cookie.properties!)
        }
        let data = NSKeyedArchiver.archivedData(withRootObject: cookieArray)
        
        let panel = NSSavePanel()
        panel.title = "导出 HTTP Cookies"
        panel.message = "请选择 HTTP Cookies 的保存路径。"

        panel.nameFieldStringValue = "cookie"
        panel.allowsOtherFileTypes = false
        panel.allowedFileTypes = ["plist"]
        panel.isExtensionHidden = false
        panel.canCreateDirectories = true

        panel.beginSheetModal(for: view.window!, completionHandler: { result in
            do {
                if result == NSApplication.ModalResponse.OK {
                    if let path = panel.url?.path {
                        try data.write(to: URL(fileURLWithPath: path))
                        self.showInformativeMessage(infoMsg: "已经成功导出 HTTP Cookies。")
                    } else {
                        return
                    }
                }
            } catch {
                self.showErrorMessage(errorMsg: "无法导出 HTTP Cookies。")
            }
        })
    }
    
    fileprivate func importCookie() {
        let panel = NSOpenPanel()
        panel.title = "读取 HTTP Cookies"
        panel.message = "请选择要加载的 HTTP Cookies 的路径。"
        panel.allowsOtherFileTypes = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = ["plist"]
        panel.isExtensionHidden = false
        
        panel.beginSheetModal(for: view.window!) { (result) in
            do {
                if result == NSApplication.ModalResponse.OK {
                    if let path = panel.url?.path {
                        let cookieArray = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [[HTTPCookiePropertyKey: Any]]
                        if cookieArray == nil {
                            ESLog.error("invalid plist as [[HTTPCookiePropertyKey: Any]]")
                            throw NSError()
                        }
                        for cookieProp in cookieArray ?? [] {
                            if let cookie = HTTPCookie(properties: cookieProp) {
                                Alamofire.HTTPCookieStorage.shared.setCookie(cookie)
                            }
                        }
                        self.showInformativeMessage(infoMsg: "已经成功读取 HTTP Cookies。")
                        self.checkLoginStatus()
                    } else {
                        return
                    }
                }
            } catch {
                self.showErrorMessage(errorMsg: "无法读取 HTTP Cookies。")
            }
        }
    }

    @IBAction func loginViaCookies(_ sender: NSButton) {
        let infoAlert: NSAlert = NSAlert()
        infoAlert.messageText = "确认格式"
        infoAlert.informativeText = "要提供哪种类型的 HTTP Cookies？"
        infoAlert.addButton(withTitle: "plist 持久化格式")
        infoAlert.addButton(withTitle: "HTTP Plain 纯文本格式")
        infoAlert.addButton(withTitle: "算了")
        infoAlert.alertStyle = NSAlert.Style.informational
        infoAlert.beginSheetModal(for: view.window!) { returnCode in
            if returnCode == .alertSecondButtonReturn {
                self.cookieParserVC.delegate = self
                self.presentAsSheet(self.cookieParserVC)
            } else if returnCode == .alertFirstButtonReturn {
                self.importCookie()
            }
        }
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
                self.exportCookieButton.isEnabled = true
            } else {
                self.exportCookieButton.isEnabled = false
                self.UIDelegate?.lockIcon()
                if LoginHelper.lastLoginUserName != "{null}" {
                    self.successImage.image = NSImage(named: "NSStatusUnavailable")
                    self.loginStateText.stringValue = "登入身份已过期。"
                    if self.view.window == nil {
                        LoginHelper.lastLoginUserName = "{null}"
                    }
                    LoginHelper.lastLoginUserName = "{null}"
                } else {
                    self.successImage.image = NSImage(named: "NSStatusNone")
                    self.loginStateText.stringValue = "您尚未登入。"
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
    
    func showInformativeMessage(infoMsg: String) {
        let infoAlert: NSAlert = NSAlert()
        infoAlert.informativeText = infoMsg
        infoAlert.messageText = "提醒"
        infoAlert.addButton(withTitle: "嗯")
        infoAlert.alertStyle = NSAlert.Style.informational
        infoAlert.beginSheetModal(for: view.window!)
        ESLog.info("informative message thrown. message: ", infoMsg)
    }
}
