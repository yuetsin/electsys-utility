//
//  AboutViewController.swift
//  cai-yun
//
//  Created by yuxiqian on 2018/10/2.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Cocoa

class AboutViewController: NSViewController {
    
    var windowController: NSWindowController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")
        let pI = ProcessInfo.init()
        let systemVersion = pI.operatingSystemVersionString


        self.versionLabel.stringValue = "App 版本 \(version ?? "未知") (\(build ?? "未知"))"
        
        self.systemLabel.stringValue = "运行在 macOS \(systemVersion)"
        
    }
    @IBAction func turnCredits(_ sender: NSButton) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        windowController = storyboard.instantiateController(withIdentifier: "Credits Window Controller") as? NSWindowController
        windowController?.showWindow(sender)
    }
    
    @IBAction func goToGithubPages(_ sender: NSButton) {
        if let url = URL(string: "https://github.com/yuxiqian/Electsys-Utility"), NSWorkspace.shared.open(url) {
            // successfully opened
        }
    }
    
    @IBAction func mailMe(_ sender: NSButton) {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")
        let pI = ProcessInfo.init()
        let systemVersion = pI.operatingSystemVersionString
        let mailService = NSSharingService(named: NSSharingService.Name.composeEmail)!
        mailService.recipients = ["akaza_akari@sjtu.edu.cn"]
        mailService.subject = "Electsys Utility Feedback"
        mailService.perform(withItems: ["\n\nSystem version: \(systemVersion)\nApp version: \(version ?? "unknown"), build \(build ?? "unknown")"])
    }
    
    @IBAction func shutWindow(_ sender: NSButton) {
        self.view.window?.close()
    }
    
    
    @IBOutlet weak var versionLabel: NSTextField!
    @IBOutlet weak var systemLabel: NSTextField!
}
