//
//  PreferencesViewController.swift
//  Electsys Utility
//
//  Created by 法好 on 2019/9/15.
//  Copyright © 2019 yuxiqian. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        readPreferences()
    }
    
    
    @IBOutlet weak var debugLevelMenuItem: NSMenuItem!
    @IBOutlet weak var traceLevelMenuItem: NSMenuItem!
    

    @IBOutlet var galleryDisplayStylePopUpSelector: NSPopUpButton!
    @IBOutlet var gpaCalculatingStrategyPopUpSelector: NSPopUpButton!

    @IBOutlet var hidePersonalInfoChecker: NSButton!
    @IBOutlet var autoFillTokenChecker: NSButton!
    @IBOutlet var userNameToken: NSTextField!
    @IBOutlet var passWordToken: NSSecureTextField!
    @IBOutlet var saveCredentialButton: NSButton!

    @IBAction func generalStylePopUpButtonTapped(_ sender: NSPopUpButton) {
        savePreferences()
    }

    @IBAction func gpaPopUpButtonTapped(_ sender: NSPopUpButton) {
        savePreferences()
    }

    @IBAction func hideCheckBoxChecked(_ sender: NSButton) {
        savePreferences()
    }

    @IBAction func autoFillBoxChecked(_ sender: NSButton) {
        disableTextBox()
        savePreferences()
    }

    @IBAction func saveCredentialButtonTapped(_ sender: NSButton) {
        savePreferences()
    }

    func disableTextBox() {
        // due to login strategy migration, auto-fill feature is disabled.
        return
//        if autoFillTokenChecker.state == .on {
//            userNameToken.isEnabled = true
//            passWordToken.isEnabled = true
//            saveCredentialButton.isEnabled = true
//        } else {
//            userNameToken.isEnabled = false
//            passWordToken.isEnabled = false
//            saveCredentialButton.isEnabled = false
//        }
    }

    @IBAction func removeCertificates(_ sender: NSButton) {
        questionMe(questionMsg: "您确定要清除本地凭据缓存吗？", handler: {
            self.autoFillTokenChecker.state = .off
            self.userNameToken.stringValue = ""
            self.passWordToken.stringValue = ""
            self.disableTextBox()

            PreferenceKits.autoFillTokens = false
            PreferenceKits.autoFillUserName = ""
            PreferenceKits.autoFillPassWord = ""
            PreferenceKits.removeCertificates()

            self.showNormalMessage(infoMsg: "已成功清除凭据缓存。")
        })
    }

    @IBAction func removeLocalCookies(_ sender: NSButton) {
        questionMe(questionMsg: "您确定要清除本地 HTTP Cookies 吗？", handler: {
            LoginHelper.removeCookie()
            self.showNormalMessage(infoMsg: "已成功清除 HTTP Cookies。")
        })
    }

    @IBAction func showLoggings(_ sender: NSButton) {
        let ws = NSWorkspace.shared
        if let appUrl = ws.urlForApplication(withBundleIdentifier: "com.apple.Console") {
            try! ws.launchApplication(at: appUrl,
                                      options: NSWorkspace.LaunchOptions.default,
                                      configuration: [:])
        }
    }

    func showNormalMessage(infoMsg: String) {
        let infoAlert: NSAlert = NSAlert()
        infoAlert.informativeText = infoMsg
        infoAlert.messageText = "提示"
        infoAlert.addButton(withTitle: "嗯")
        infoAlert.alertStyle = NSAlert.Style.informational
        infoAlert.beginSheetModal(for: view.window!)
        
        ESLog.info("informative message: ", infoMsg)
    }

    func readPreferences() {
        PreferenceKits.readPreferences()
        galleryDisplayStylePopUpSelector.selectItem(at: PreferenceKits.courseDisplayStrategy.rawValue)
        gpaCalculatingStrategyPopUpSelector.selectItem(at: PreferenceKits.gpaStrategy.rawValue)

        if PreferenceKits.hidePersonalInfo {
            hidePersonalInfoChecker.state = .on
        } else {
            hidePersonalInfoChecker.state = .off
        }

        if PreferenceKits.autoFillTokens {
            autoFillTokenChecker.state = .on
        } else {
            autoFillTokenChecker.state = .off
        }

        userNameToken.stringValue = PreferenceKits.autoFillUserName
        passWordToken.stringValue = PreferenceKits.autoFillPassWord
        disableTextBox()
    }

    func savePreferences() {
        PreferenceKits.courseDisplayStrategy = CourseNameDisplayStrategy(rawValue: galleryDisplayStylePopUpSelector.indexOfSelectedItem) ?? .nameAndTeacher
        PreferenceKits.gpaStrategy = GPACalculationStrategy(rawValue: gpaCalculatingStrategyPopUpSelector.indexOfSelectedItem) ?? .SJTU_4_3

        PreferenceKits.hidePersonalInfo = hidePersonalInfoChecker.state == .on
        PreferenceKits.autoFillTokens = autoFillTokenChecker.state == .on

        if autoFillTokenChecker.state == .on {
            PreferenceKits.autoFillUserName = userNameToken.stringValue
            PreferenceKits.autoFillPassWord = passWordToken.stringValue
        }

        PreferenceKits.savePreferences()
    }

    @IBAction func debugLevelTriggered(_ sender: NSPopUpButton) {
        switch sender.selectedTag() {
        case 0:
            // fault
            ESLog.minLevel = .fault
        case 1:
            // error
            ESLog.minLevel = .error
        case 2:
            // info
            ESLog.minLevel = .info
        case 3:
            // debug
            ESLog.minLevel = .debug
        case 5:
            // disabled
            ESLog.minLevel = .off
        default:
            // nothing to do
            ESLog.error("gotta invalid debug level ", sender.selectedTag())
        }
    }
    
    func questionMe(questionMsg: String, handler: @escaping () -> Void) {
        let questionAlert: NSAlert = NSAlert()
        questionAlert.informativeText = questionMsg
        questionAlert.messageText = "操作确认"
        questionAlert.addButton(withTitle: "确认")
        questionAlert.addButton(withTitle: "手滑了")
        questionAlert.alertStyle = NSAlert.Style.critical
        questionAlert.beginSheetModal(for: view.window!) { returnCode in
            if returnCode == NSApplication.ModalResponse.alertFirstButtonReturn {
                ESLog.info("user gives positive response to the question ", questionMsg)
                handler()
            } else {
                ESLog.info("user gives negative response to the question ", questionMsg)
            }
        }
    }
}
