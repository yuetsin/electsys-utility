//
//  ViewController.swift
//  courseSync
//
//  Created by yuxiqian on 2018/8/28.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Foundation
import Cocoa

class CreditsViewController : NSViewController {
    @IBAction func closeWindow(_ sender: NSButton) {
       self.view.window?.close()
    }
    
    override func viewWillDisappear() {
        let application = NSApplication.shared
        application.stopModal()
    }
}
