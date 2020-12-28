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
    
    static var updater: GitHubUpdater {
        let updater = GitHubUpdater()
        updater.user = "yuetsin"
        updater.repository = "electsys-utility"
        ESLog.info("updater initialized")
        return updater
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")
        let pI = ProcessInfo.init()
        let systemVersion = pI.operatingSystemVersionString

        ESLog.info("app version: %@", version as? String ?? "unknown")
        ESLog.info("system version: %@", systemVersion)
        
        self.versionLabel.stringValue = "App 版本 \(version ?? "未知") (\(build ?? "未知"))"
        self.systemLabel.stringValue = "运行在 macOS \(systemVersion)"
    }
    @IBAction func turnCredits(_ sender: NSButton) {
//        let storyboard = NSStoryboard(name: "Main", bundle: nil)
//        windowController = storyboard.instantiateController(withIdentifier: "Credits Window Controller") as? NSWindowController
//        windowController?.showWindow(sender)
        (self.view.window?.contentViewController as! MainViewController).visitCreditsPage()
//        (self.parent as! MainViewController).visitCreditsPage()
    }
    
    @IBAction func goToGithubPages(_ sender: NSButton) {
        if let url = URL(string: "https://github.com/yuetsin/electsys-utility"), NSWorkspace.shared.open(url) {
            ESLog.info("goes to github pages")
        }
    }

    
    @IBAction func shutWindow(_ sender: NSButton) {
        self.view.window?.close()
    }
    
    @IBAction func checkForUpdates(_ sender: NSButton) {
        AboutViewController.updater.checkForUpdates(sender)
    }
    
    
    @IBOutlet weak var versionLabel: NSTextField!
    @IBOutlet weak var systemLabel: NSTextField!
}
