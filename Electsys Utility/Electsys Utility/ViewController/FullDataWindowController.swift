//
//  FullDataWindowController.swift
//  Electsys Utility
//
//  Created by yuxiqian on 2018/12/9.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Cocoa

class FullDataWindowController: NSWindowController {

    @IBOutlet weak var toolBar: NSToolbar!
    @IBOutlet weak var useBetaSwitcher: NSToolbarItem!
    @IBOutlet weak var infoChecker: NSToolbarItem!
    
    @IBAction func switchBeta(_ sender: NSToolbarItem) {
        (self.contentViewController as! FullDataViewController).setLayoutType(.shrink)
        if !(self.contentViewController as! FullDataViewController).shouldRequestBeta {
//            sender.label = "使用 “Beta” 版数据"
            toolBar.selectedItemIdentifier = sender.itemIdentifier
            (self.contentViewController as! FullDataViewController).shouldRequestBeta = true
        } else {
//            sender.label = "使用稳定版数据"
            toolBar.selectedItemIdentifier = nil
            (self.contentViewController as! FullDataViewController).shouldRequestBeta = false
        }
    }
    
    @IBAction func showInfo(_ sender: NSToolbarItem) {
        (self.contentViewController as! FullDataViewController).showDataInfo()
    }
    override func windowDidLoad() {
        super.windowDidLoad()
        infoChecker.isEnabled = false
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
}
