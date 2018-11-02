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
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var yearSelector: NSPopUpButton!
    @IBOutlet weak var termSelector: NSPopUpButton!
    
    @IBOutlet weak var schoolSelector: NSPopUpButton!
    @IBOutlet weak var teacherName: NSComboBox!
    @IBOutlet weak var titleSelector: NSPopUpButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
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
        var frame: NSRect = (self.view.window?.frame)!
        frame.size = NSSize(width: 480, height: 129)
        self.view.window?.setFrame(frame, display: true, animate: true)
    }
    
    func expandFrame() {
        var frame: NSRect = (self.view.window?.frame)!
        frame.size = NSSize(width: 480, height: 289)
        self.view.window?.setFrame(frame, display: true, animate: true)
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
