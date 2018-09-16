//
//  FullDataViewController.swift
//  Sync Utility
//
//  Created by yuxiqian on 2018/9/5.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON

class FullDataViewController: NSViewController {
    
    var courses: [Curricula] = []
    var upperHall: [String] = []
    var middleHall: [String] = []
    var lowerHall: [String] = []
    var eastUpperHall: [String] = []
    var eastMiddleHall: [String] = []
    var eastLowerHall: [String] = []
    
    var toTheEnd: Bool = true
    var isOddWeekAndNotEvenWeek = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        for year in 0...8 {
            yearSelector.addItem(withTitle: ConvertToString(Year(rawValue: 2018 - year)!))
        }
    }
    
    func clearLists() {
        courses.removeAll()
        upperHall.removeAll()
        middleHall.removeAll()
        lowerHall.removeAll()
        eastUpperHall.removeAll()
        eastMiddleHall.removeAll()
        eastLowerHall.removeAll()
    }
    
    
    @IBAction func oddEvenSelected(_ sender: NSButton) {
        if sender.title == "单周" {
            isOddWeekAndNotEvenWeek = true
        } else {
            isOddWeekAndNotEvenWeek = false
        }
    }
    
    @IBAction func startQuery(_ sender: NSButton) {
        shrinkFrame()
        clearLists()
        getJson()
    }
    
    @IBOutlet weak var yearSelector: NSPopUpButton!
    @IBOutlet weak var termSelector: NSPopUpButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var buildingSelector: NSPopUpButton!
    @IBOutlet weak var roomSelector: NSPopUpButton!
    @IBOutlet weak var weekDaySelector: NSPopUpButton!

    @IBOutlet weak var oneButton: NSButton!
    @IBOutlet weak var twoButton: NSButton!
    @IBOutlet weak var threeButton: NSButton!
    @IBOutlet weak var fourButton: NSButton!
    @IBOutlet weak var fiveButton: NSButton!
    @IBOutlet weak var sixButton: NSButton!
    @IBOutlet weak var sevenButton: NSButton!
    @IBOutlet weak var eightButton: NSButton!
    @IBOutlet weak var nineButton: NSButton!
    @IBOutlet weak var tenButton: NSButton!
    @IBOutlet weak var elevenButton: NSButton!
    @IBOutlet weak var twelveButton: NSButton!
    
    
    @IBAction func iconButtonTapped(_ sender: NSButton) {
        print(sender.identifier?.rawValue ?? "Nil")
    }
    
    

    func getJson() {
        let jsonUrl = "\(jsonHeader)\(yearSelector.selectedItem?.title.replacingOccurrences(of: "-", with: "_") ?? "__invalid__")_\(rawValueToInt((termSelector.selectedItem?.title)!)).json"
        print(jsonUrl)
        self.progressIndicator.isHidden = false
        Alamofire.request(jsonUrl).response(completionHandler: { response in
            if response.response == nil {
                self.progressIndicator.isHidden = true
                return
            } else {
                DispatchQueue.global().async {
                    do {
                        let curricula = try JSON(data: response.data!)
                        if let curArray = curricula["data"].array {
                            for curJson in curArray {
                                let cur = generateCur(curJson)
                                for classRoom in cur.getRelatedClassroom() {
                                    self.sortClassroom(classRoom)
                                }
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
                        self.progressIndicator.isHidden = true
                        self.sortLists()
                        self.pushPopListData(self.buildingSelector)
                        self.expandFrame()
                        // success!
                    }
                }
            }
        })
    }
    
    @IBAction func pushPopListData(_ sender: NSPopUpButton) {
        roomSelector.removeAllItems()
        switch buildingSelector.selectedItem?.title {
        case "闵行校区上院":
            roomSelector.addItems(withTitles: upperHall)
            break
        case "闵行校区中院":
            roomSelector.addItems(withTitles: middleHall)
            break
        case "闵行校区下院":
            roomSelector.addItems(withTitles: lowerHall)
            break
        case "闵行校区东上院":
            roomSelector.addItems(withTitles: eastUpperHall)
            break
        case "闵行校区东中院":
            roomSelector.addItems(withTitles: eastMiddleHall)
            break
        case "闵行校区东下院":
            roomSelector.addItems(withTitles: eastLowerHall)
            break
        default:
            roomSelector.addItem(withTitle: "ˊ_>ˋ")
        }
    }

    
    func sortClassroom(_ str: String) {
        if str.starts(with: "上院") {
            if !upperHall.contains(str) {
                upperHall.append(str)
            }
        } else if str.starts(with: "中院") {
            if !middleHall.contains(str) {
                middleHall.append(str)
            }
        } else if str.starts(with: "下院") {
            if !lowerHall.contains(str) {
                lowerHall.append(str)
            }
        } else if str.starts(with: "东上院") {
            if !eastUpperHall.contains(str) {
                eastUpperHall.append(str)
            }
        } else if str.starts(with: "东中院") {
            if !eastMiddleHall.contains(str) {
                eastMiddleHall.append(str)
            }
        } else if str.starts(with: "东下院") {
            if !eastLowerHall.contains(str) {
                eastLowerHall.append(str)
            }
        }
    }
    
    func showErrorMessage(errorMsg: String) {
        let errorAlert: NSAlert = NSAlert()
        errorAlert.messageText = "出错啦"
        errorAlert.informativeText = errorMsg
        errorAlert.addButton(withTitle: "嗯")
        errorAlert.alertStyle = NSAlert.Style.critical
        errorAlert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
    
    func sortLists() {
        upperHall.sort()
        middleHall.sort()
        lowerHall.sort()
        eastUpperHall.sort()
        eastMiddleHall.sort()
        eastLowerHall.sort()
    }
    
    func shrinkFrame() {
        var frame: NSRect = (self.view.window?.frame)!
        frame.size = NSSize(width: 480, height: 101)
        self.view.window?.setFrame(frame, display: true, animate: true)
    }
    
    func expandFrame() {
        var frame: NSRect = (self.view.window?.frame)!
        frame.size = NSSize(width: 480, height: 337)
        self.view.window?.setFrame(frame, display: true, animate: true)
    }
}
