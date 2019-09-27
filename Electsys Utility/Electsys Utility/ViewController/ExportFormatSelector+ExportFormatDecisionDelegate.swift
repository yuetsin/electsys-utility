//
//  ExportFormatSelector.swift
//  Electsys Utility
//
//  Created by 法好 on 2019/9/27.
//  Copyright © 2019 yuxiqian. All rights reserved.
//

import Cocoa

class ExportFormatSelector: NSViewController {
    
    var delegate: ExportFormatDecisionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func exportPlainText(_ sender: NSButton) {
        delegate?.exportPlainText()
    }
    
    @IBAction func exportJSONFormat(_ sender: NSButton) {
        delegate?.exportJSONFormat()
    }
}

protocol ExportFormatDecisionDelegate {
    func exportPlainText() -> ()
    func exportJSONFormat() -> ()
}
