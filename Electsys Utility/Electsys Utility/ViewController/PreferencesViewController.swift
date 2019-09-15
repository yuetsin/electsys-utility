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
    
    @IBOutlet weak var galleryDisplayStylePopUpSelector: NSPopUpButton!
    @IBOutlet weak var gpaCalculatingStrategyPopUpSelector: NSPopUpButton!
    
    @IBOutlet weak var hidePersonalInfoChecker: NSButton!
    @IBOutlet weak var autoFillTokenChecker: NSButton!
    @IBOutlet weak var userNameToken: NSTextField!
    @IBOutlet weak var passWordToken: NSSecureTextField!
    @IBOutlet weak var saveCredentialButton: NSButton!
    
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
        if autoFillTokenChecker.state == .on {
            userNameToken.isEnabled = true
            passWordToken.isEnabled = true
        } else {
            userNameToken.isEnabled = false
            passWordToken.isEnabled = false
        }
    }
    
    @IBAction func removeCertificates(_ sender: NSButton) {
        autoFillTokenChecker.state = .off
        userNameToken.stringValue = ""
        passWordToken.stringValue = ""
        disableTextBox()
        
        PreferenceKits.autoFillTokens = false
        PreferenceKits.autoFillUserName = ""
        PreferenceKits.autoFillPassWord = ""
        PreferenceKits.savePreferences()
        
        showNormalMessage(infoMsg: "已成功清除凭据缓存。")
    }
    
    func showNormalMessage(infoMsg: String) {
        let infoAlert: NSAlert = NSAlert()
        infoAlert.informativeText = infoMsg
        infoAlert.messageText = "提示"
        infoAlert.addButton(withTitle: "嗯")
        infoAlert.alertStyle = NSAlert.Style.informational
        infoAlert.beginSheetModal(for: view.window!)
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
}
