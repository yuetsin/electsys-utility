//
//  FullDataViewController.swift
//  Sync Utility
//
//  Created by yuxiqian on 2018/9/5.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Cocoa

class FullDataViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func questionMark(_ sender: NSButton) {
        let errorAlert: NSAlert = NSAlert()
        errorAlert.messageText = "学期说明"
        errorAlert.informativeText = "第一学期指每一学年的秋季学期。第二学期指每一学年的春季学期和夏季小学期。"
        errorAlert.alertStyle = NSAlert.Style.informational
        errorAlert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
}
