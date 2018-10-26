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
    
    let specialSep = "$_$"
    
    var courses: [Curricula] = []
    var upperHall: [String] = []
    var middleHall: [String] = []
    var lowerHall: [String] = []
    var eastUpperHall: [String] = []
    var eastMiddleHall: [String] = []
    var eastLowerHall: [String] = []
    var arrangement: [String] = [String].init(repeating: "空教室", count: 14)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressIndicator.startAnimation(nil)
        setWeekPop(start: 1, end: 16)
        // Do view setup here.
        for year in 0...8 {
            yearSelector.addItem(withTitle: ConvertToString(Year(rawValue: 2018 - year)!))
        }
    }
    
    func setWeekPop(start: Int, end: Int) {
        weekSelector.removeAllItems()
        for i in start...end {
            weekSelector.addItem(withTitle: "第 \(i) 周")
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

    @IBOutlet weak var weekSelector: NSPopUpButton!
    
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
    
    @IBOutlet weak var sortBox: NSBox!
    @IBOutlet weak var detailBox: NSBox!
    
    
    @IBAction func iconButtonTapped(_ sender: NSButton) {
        let id = Int((sender.identifier?.rawValue)!)
        let obj = arrangement[id! - 1].components(separatedBy: specialSep)
        if obj.count == 2 {
            showCourseInfo(titleMsg: obj[0], infoMsg: obj[1])
        } else {
            showCourseInfo(titleMsg: "空教室", infoMsg: "这里什么都没有…")
        }
    }

    @IBAction func yearPopTapped(_ sender: NSPopUpButton) {
        shrinkFrame()
    }
    
    @IBAction func termPopTapped(_ sender: NSPopUpButton) {
        shrinkFrame()
        if sender.selectedItem?.title == "夏季小学期" {
            setWeekPop(start: 19, end: 22)
        } else {
            setWeekPop(start: 1, end: 16)
        }
    }
    
    func getJson() {
        let jsonUrl = "\(jsonHeader)\(yearSelector.selectedItem?.title.replacingOccurrences(of: "-", with: "_") ?? "__invalid__")_\(rawValueToInt((termSelector.selectedItem?.title)!)).json"
//        print(jsonUrl)
        self.sortBox.title = "\(self.yearSelector.selectedItem?.title ?? "未知") 学年\(self.termSelector.selectedItem?.title ?? " 未知学期")"
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
        case "闵行校区上院"?:
            roomSelector.addRoomItems(withTitles: upperHall)
            break
        case "闵行校区中院"?:
            roomSelector.addRoomItems(withTitles: middleHall)
            break
        case "闵行校区下院"?:
            roomSelector.addRoomItems(withTitles: lowerHall)
            break
        case "闵行校区东上院"?:
            roomSelector.addRoomItems(withTitles: eastUpperHall)
            break
        case "闵行校区东中院"?:
            roomSelector.addRoomItems(withTitles: eastMiddleHall)
            break
        case "闵行校区东下院"?:
            roomSelector.addRoomItems(withTitles: eastLowerHall)
            break
        default:
            roomSelector.addItem(withTitle: "ˊ_>ˋ")
        }
        updateBoxes(sender)
    }

    
    func sortClassroom(_ str: String) {
        let str = str.replacingOccurrences(of: "院", with: "院 ")
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
        frame.size = NSSize(width: 480, height: 89)
        self.view.window?.setFrame(frame, display: true, animate: true)
    }
    
    func expandFrame() {
        var frame: NSRect = (self.view.window?.frame)!
        frame.size = NSSize(width: 480, height: 317)
        self.view.window?.setFrame(frame, display: true, animate: true)
    }

    
    @IBAction func updateBoxes(_ sender: NSPopUpButton) {
        for i in 1...12 {
            drawBox(id: i)
        }
        arrangement = [String].init(repeating: "空教室", count: 14)

        
        let currentWeek = hanToInt(self.weekSelector.selectedItem?.title)
        let weekDay = dayToInt.index(of: (self.weekDaySelector.selectedItem?.title)!)
        detailBox.title = "\(self.roomSelector.selectedItem?.title ?? "某教室")，\(self.weekSelector.selectedItem?.title ?? "某周")\(self.weekDaySelector.selectedItem?.title ?? "某日")教室安排情况"
        
        if let room = self.roomSelector.selectedItem?.title.sanitize() {
            for cur in courses {
                if !cur.getRelatedClassroom().contains(room) {
                    continue
                }

                if cur.startWeek > currentWeek { continue }
                if cur.endWeek < currentWeek { continue }
                if currentWeek % 2 == 1 {
                    // 单周
                    for arr in cur.oddWeekArr {
                        if arr.weekDay != weekDay {
                            continue
                        }
                        for lessonIndex in arr.startsAt...arr.endsAt {
                            drawBox(id: lessonIndex, population: cur.studentNumber)
                            arrangement[lessonIndex - 1] = "\(cur.name)\(specialSep)开课院系：\(cur.holderSchool)\n教师：\(cur.teacherName) \(cur.teacherTitle)\n人数：\(cur.studentNumber)"
                        }
                    }
                } else {
                    // 双周
                    for arr in cur.evenWeekArr {
                        if arr.weekDay != weekDay {
                            continue
                        }
                        for lessonIndex in arr.startsAt...arr.endsAt {
                            drawBox(id: lessonIndex, population: cur.studentNumber)
                            arrangement[lessonIndex - 1] = "\(cur.name)\(specialSep)开课院系：\(cur.holderSchool)\n教师：\(cur.teacherName) \(cur.teacherTitle)\n人数：\(cur.studentNumber)"
                        }
                    }
                }
            }
        } else {
            detailBox.title = "教室占用情况"
        }
    }
    
    func drawBox(id: Int, population: Int = -1) {
        var color: NSColor?
        if population == -1 {
            color = getColor(name: "empty")
        } else if population < 25 {
            color = getColor(name: "light")
        } else if population < 50 {
            color = getColor(name: "medium")
        } else if population < 100 {
            color = getColor(name: "heavy")
        } else {
            color = getColor(name: "full")
        }
        let colorBox = NSImage(color: color!, size: NSSize(width: 25, height: 25))
        switch id {
        case 1:
            oneButton.image = colorBox
            break
        case 2:
            twoButton.image = colorBox
            break
        case 3:
            threeButton.image = colorBox
            break
        case 4:
            fourButton.image = colorBox
            break
        case 5:
            fiveButton.image = colorBox
            break
        case 6:
            sixButton.image = colorBox
            break
        case 7:
            sevenButton.image = colorBox
            break
        case 8:
            eightButton.image = colorBox
            break
        case 9:
            nineButton.image = colorBox
            break
        case 10:
            tenButton.image = colorBox
            break
        case 11:
            elevenButton.image = colorBox
            break
        case 12:
            twelveButton.image = colorBox
            break
        default:
            break
        }
    }
    
    func showCourseInfo(titleMsg: String, infoMsg: String) {
        let infoAlert: NSAlert = NSAlert()
        infoAlert.messageText = titleMsg
        infoAlert.informativeText = infoMsg
        infoAlert.addButton(withTitle: "嗯")
        infoAlert.alertStyle = NSAlert.Style.informational
        infoAlert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
}


extension NSImage {
    convenience init(color: NSColor, size: NSSize) {
        self.init(size: size)
        lockFocus()
        color.drawSwatch(in: NSRect(origin: .zero, size: size))
        self.draw(in: NSRect(origin: .zero, size: size),
                 from: NSRect(origin: .zero, size: self.size),
                 operation: .color, fraction: 1)
        unlockFocus()
    }
}

@objc extension NSPopUpButton {
    func addRoomItems(withTitles items: [String]) {
        var lastIndex: Int?
        for item in items {
            let curIndex: Int = Int(item.removeFloorCharacters().prefix(1))!
//            print("cur: \(curIndex), last: \(lastIndex)")
            if lastIndex != nil {
                if curIndex != lastIndex {
                    lastIndex = curIndex
//                    print("should add sep")
                    self.addItem(withTitle: "MY_MENU_SEPARATOR")
                }
            } else {
                lastIndex = curIndex
            }
            self.addItem(withTitle: item)
        }
    }
}

