//
//  AppDelegate.swift
//  courseSync
//
//  Created by yuxiqian on 2018/8/29.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Cocoa

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
  
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
//
//    @IBAction func aboutWindow(_ sender: NSButton) {
//        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
//        windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "About Window Controller")) as? NSWindowController
//        windowController?.showWindow(sender)
//    }

//    @IBAction func openCreditsWindow(_ sender: NSButton) {
//        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
//        windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "Credits Window Controller")) as? NSWindowController
//        windowController?.showWindow(sender)
//    }
    
    @IBAction func openGithubPage(_ sender: NSButton) {
        if let url = URL(string: "https://github.com/yuxiqian/Electsys-Utility"), NSWorkspace.shared.open(url) {
            // successfully opened
        }
    }
    
    @IBAction func mailAuthor(_ sender: NSButton) {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")
        let pI = ProcessInfo.init()
        let systemVersion = pI.operatingSystemVersionString
        let mailService = NSSharingService(named: NSSharingService.Name.composeEmail)!
        mailService.recipients = ["akaza_akari@sjtu.edu.cn"]
        mailService.subject = "Electsys Utility Feedback"
        mailService.perform(withItems: ["\n\nSystem version: \(systemVersion)\nApp version: \(version ?? "unknown"), build \(build ?? "unknown")"])
    }
}

