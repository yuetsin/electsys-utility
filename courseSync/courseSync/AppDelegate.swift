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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
  
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    @IBAction func openCreditsWindow(_ sender: NSButton) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let creditsWindowController = storyboard.instantiateController(withIdentifier: "Credits Window Controller") as! NSWindowController
            creditsWindowController.showWindow(sender)
    }
    
    @IBAction func openGithubPage(_ sender: NSButton) {
        if let url = URL(string: "https://github.com/yuxiqian/Sjtu-Schedule-Sync-Utility"), NSWorkspace.shared.open(url) {
            // successfully opened
        }
    }
}

