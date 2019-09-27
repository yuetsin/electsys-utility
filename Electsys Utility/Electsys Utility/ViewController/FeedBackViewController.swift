//
//  FeedBackViewController.swift
//  Electsys Utility
//
//  Created by 法好 on 2019/9/16.
//  Copyright © 2019 yuxiqian. All rights reserved.
//

import Cocoa

class FeedBackViewController: NSViewController {
    
    var issueType: String = "App 功能问题"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")
        self.versionField.stringValue = "app version \(version ?? "N/A") (\(build ?? "N/A"))"
    }
    @IBAction func visitGitHubIssuePages(_ sender: NSButton) {
        if let url = URL(string: "https://github.com/yuetsin/electsys-utility/issues"), NSWorkspace.shared.open(url) {
            // successfully opened
        }
    }
    
    @IBAction func switchIssueType(_ sender: NSButton) {
        issueType = sender.title
    }
    
    @IBOutlet weak var versionField: NSTextField!
    @IBOutlet weak var subjectField: NSTextField!
    @IBOutlet var contentField: NSTextView!
    
    @IBAction func sendEmail(_ sender: NSButton) {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")
        let pI = ProcessInfo.init()
        let systemVersion = pI.operatingSystemVersionString
        let mailService = NSSharingService(named: NSSharingService.Name.composeEmail)!
        mailService.recipients = ["akaza_akari@sjtu.edu.cn"]
        mailService.subject = "[es-util feedback] [\(issueType)] " + subjectField.stringValue
        mailService.perform(withItems: [contentField.string + "\n\nSystem version: \(systemVersion)\nApp version: \(version ?? "unknown"), build \(build ?? "unknown")"])
    }
}
