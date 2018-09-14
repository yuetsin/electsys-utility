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

    var windowController: NSWindowController?
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
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "Credits Window Controller")) as? NSWindowController
        windowController?.showWindow(sender)
    }
    
    @IBAction func openGithubPage(_ sender: NSButton) {
        if let url = URL(string: "https://github.com/yuxiqian/Electsys-Utility"), NSWorkspace.shared.open(url) {
            // successfully opened
        }
    }
}

