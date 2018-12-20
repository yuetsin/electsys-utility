//
//  HtmlGetViewController.swift
//  Sync Utility
//
//  Created by yuxiqian on 2018/8/30.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Foundation
import Cocoa

class htmlGetViewController: NSViewController {
    
    weak var delegate: inputHtmlDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
//    override func viewDidDisappear() {
//        let application = NSApplication.shared
//        application.stopModal()
//        super.viewDidDisappear()
//    }
    
    @IBOutlet var htmlContentField: NSTextView!
    
    @IBAction func browseHTMLFile(_ sender: NSButton) {
        let openHTMLPanel = NSOpenPanel()
        openHTMLPanel.allowsMultipleSelection = false
        openHTMLPanel.allowedFileTypes = ["html"]
        openHTMLPanel.directoryURL = nil
        openHTMLPanel.beginSheetModal(for: self.view.window!, completionHandler: { returnCode in
            if returnCode == NSApplication.ModalResponse.OK {
                do {
                    let htmlDocUrl = openHTMLPanel.url
                    let htmlDocData = String(data: try NSData(contentsOf: htmlDocUrl!) as Data, encoding: String.Encoding.utf8)
                    self.htmlContentField.string = htmlDocData ?? """
                    <head>
                    
                    
                    </head>
                    """
                } catch {
                    self.showErrorMessage(errorMsg: "未能置入此 HTML 文稿。")
                    self.htmlContentField.string = """
                    <head>
                    
                    
                    </head>
                    """
                }
            }
        })
    }
    
    
    @IBAction func OKAndClose(_ sender: NSButton) {
        self.delegate?.checkDataInput(htmlData: self.htmlContentField.string)
        self.view.window?.close()
    }
    
    @IBAction func goToElectSys(_ sender: NSButton) {
        if let url = URL(string: "http://electsys.sjtu.edu.cn/"), NSWorkspace.shared.open(url) {
            // successfully opened
        }
    }
    
    @IBAction func cancelAndClose(_ sender: NSButton) {
        self.delegate?.cancelDataInput()
        self.view.window?.close()
    }
    
    func showErrorMessage(errorMsg: String) {
        let errorAlert: NSAlert = NSAlert()
        errorAlert.informativeText = errorMsg
        errorAlert.messageText = "出错啦"
        errorAlert.alertStyle = NSAlert.Style.critical
        errorAlert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
}
