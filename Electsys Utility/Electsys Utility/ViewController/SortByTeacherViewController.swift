//
//  SortByTeacherViewController.swift
//  Electsys Utility
//
//  Created by yuxiqian on 2018/11/2.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON

class SortByTeacherViewController: NSViewController {
    
    var courses: [Curricula] = []
    var schools: [String] = []
    var titles: [String] = []
    
    let smallSize: NSSize = NSSize(width: 480, height: 79)
    let bigSize: NSSize = NSSize(width: 480, height: 239)
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var yearSelector: NSPopUpButton!
    @IBOutlet weak var termSelector: NSPopUpButton!
    
    @IBOutlet weak var schoolSelector: NSPopUpButton!
    @IBOutlet weak var teacherName: NSComboBox!
    @IBOutlet weak var titleSelector: NSPopUpButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.preferredContentSize = smallSize
        for year in 0...8 {
            yearSelector.addItem(withTitle: ConvertToString(Year(rawValue: 2018 - year)!))
        }
    }
    
    @IBAction func startQuery(_ sender: NSButton) {
        shrinkFrame()
        clearLists()
        getJson()
    }
    
    func shrinkFrame() {
        
        let frame = self.view.window!.frame
        let heightDelta = frame.size.height - smallSize.height - 48
        let origin = NSMakePoint(frame.origin.x, frame.origin.y + heightDelta)
        let size = NSSize(width: smallSize.width, height: smallSize.height + 48)
        let newFrame = NSRect(origin: origin, size: size)
//        self.view.window?.setFrame(newFrame, display: true, animate: true)
        NSAnimationContext.runAnimationGroup({ (context) in
//            context.duration = 0.5
            self.view.window?.animator().setFrame(newFrame, display: true)
        }, completionHandler: nil)
        self.preferredContentSize = smallSize
    }
    
    func expandFrame() {
//        self.preferredContentSize = self.bigSize
        
        let frame = self.view.window!.frame
        let heightDelta = frame.size.height - bigSize.height - 48
        let origin = NSMakePoint(frame.origin.x, frame.origin.y + heightDelta)
        let size = NSSize(width: bigSize.width, height: bigSize.height + 48)
        let newFrame = NSRect(origin: origin, size: size)
//        self.view.window?.setFrame(newFrame, display: true, animate: true)
        NSAnimationContext.runAnimationGroup({ (context) in
//            context.duration = 0.5
            self.view.window?.animator().setFrame(newFrame, display: true)
        }, completionHandler: nil)
        
        self.preferredContentSize = bigSize
    }
    
    func clearLists() {
        
    }
    
    func getJson() {
        let jsonUrl = "\(jsonHeader)\(yearSelector.selectedItem?.title.replacingOccurrences(of: "-", with: "_") ?? "__invalid__")_\(rawValueToInt((termSelector.selectedItem?.title)!)).json"
        //        print(jsonUrl)

        self.progressIndicator.isHidden = false
        Alamofire.request(jsonUrl).response(completionHandler: { response in
            if response.response == nil {
                self.progressIndicator.isHidden = true
                self.showErrorMessage(errorMsg: "未能读取 \(jsonUrl)。")
                return
            } else {
                DispatchQueue.global().async {
                    do {
                        let curricula = try JSON(data: response.data!)
                        if let curArray = curricula["data"].array {
                            for curJson in curArray {
                                let cur = generateCur(curJson)
                                self.courses.append(cur)
                            }
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.showErrorMessage(errorMsg: "未能读取 \(jsonUrl)。")
                            self.progressIndicator.isHidden = true
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        self.expandFrame()
                        // success!
                    }
                }
            }
        })
    }
    
    func showErrorMessage(errorMsg: String) {
        let errorAlert: NSAlert = NSAlert()
        errorAlert.messageText = "出错啦"
        errorAlert.informativeText = errorMsg
        errorAlert.addButton(withTitle: "嗯")
        errorAlert.alertStyle = NSAlert.Style.critical
        errorAlert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }

}
