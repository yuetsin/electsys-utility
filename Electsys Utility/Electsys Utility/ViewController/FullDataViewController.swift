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
import Regex

class FullDataViewController: NSViewController {
    
    static let toolBarHeight = 56
    
    let specialSep = "$_$"
    
    var shouldRequestBeta: Bool = false
    
    var courses: [Curricula] = []
    
    var queryCoursesOnTeacher: [Curricula] = []
    var queryCoursesOnName: [Curricula] = []
    
    var upperHall: [String] = []
    var middleHall: [String] = []
    var lowerHall: [String] = []
    var eastUpperHall: [String] = []
    var eastMiddleHall: [String] = []
    var eastLowerHall: [String] = []
    
    var MinHangCampus: [String] = []
    var CRQBuilding: [String] = []
    var YYMBuilding: [String] = []
    var XuHuiCampus: [String] = []
    var LuWanCampus: [String] = []
    var FaHuaCampus: [String] = []
    var QiBaoCampus: [String] = []
    var OtherLand: [String] = []
    var SMHC: [String] = []
    var LinGangCampus: [String] = []
    
    @objc dynamic var toggleUpperHall: Bool = true
    @objc dynamic var toggleMiddleHall: Bool = true
    @objc dynamic var toggleLowerHall: Bool = true
    @objc dynamic var toggleEastUpperHall: Bool = true
    @objc dynamic var toggleEastMiddleHall: Bool = true
    @objc dynamic var toggleEastLowerHall: Bool = true
    @objc dynamic var toggleMinHangCampus: Bool = true
    @objc dynamic var toggleCRQBuilding: Bool = true
    @objc dynamic var toggleYYMBuilding: Bool = true
    @objc dynamic var toggleXuHuiCampus: Bool = true
    @objc dynamic var toggleLuWanCampus: Bool = true
    @objc dynamic var toggleFaHuaCampus: Bool = true
    @objc dynamic var toggleQiBaoCampus: Bool = true
    @objc dynamic var toggleOtherLand: Bool = true
    @objc dynamic var toggleSMHC: Bool = true
    @objc dynamic var toggleLinGangCampus: Bool = true
    
    var localTimeStamp: String = ""
    
    var arrangement: [String] = [String].init(repeating: "空教室", count: 14)
    
    var schools: [String] = []
    var teachers: [String] = []
    var titles: [String] = []
    var classnames: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressIndicator.startAnimation(nil)
        setWeekPop(start: 1, end: 16)
        // Do view setup here.
        for year in 0...8 {
            yearSelector.addItem(withTitle: ConvertToString(Year(rawValue: 2018 - year)!))
        }
    }
    
    func setEnableStats(_ stat: [Bool]) {
        self.view.window?.toolbar?.items[0].isEnabled = stat[0]
        self.view.window?.toolbar?.items[2].isEnabled = stat[1]
    }
    
    func setWeekPop(start: Int, end: Int) {
        weekSelector.removeAllItems()
        for i in start...end {
            weekSelector.addItem(withTitle: "第 \(i) 周")
        }
    }
    
    func clearLists() {
        courses.removeAll()
        schools.removeAll()
        titles.removeAll()
        teachers.removeAll()
        classnames.removeAll()
        
        upperHall.removeAll()
        middleHall.removeAll()
        lowerHall.removeAll()
        eastUpperHall.removeAll()
        eastMiddleHall.removeAll()
        eastLowerHall.removeAll()
        XuHuiCampus.removeAll()
        MinHangCampus.removeAll()
        CRQBuilding.removeAll()
        XuHuiCampus.removeAll()
        LuWanCampus.removeAll()
        FaHuaCampus.removeAll()
        QiBaoCampus.removeAll()
        OtherLand.removeAll()
        SMHC.removeAll()
        YYMBuilding.removeAll()
        LinGangCampus.removeAll()
    }
    
    @IBAction func startQuery(_ sender: NSButton) {
        setLayoutType(.shrink)
        
        yearSelector.isEnabled = false
        termSelector.isEnabled = false
        setEnableStats([false, false])
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
    
    @IBOutlet weak var tabTitleSeg: NSSegmentedControl!
    @IBOutlet weak var sortBox: NSBox!
    @IBOutlet weak var detailBox: NSBox!
    
    
    @IBOutlet weak var holdingSchoolSelector: NSPopUpButton!
    @IBOutlet weak var teacherNameCombo: NSComboBox!
    @IBOutlet weak var titleSelector: NSPopUpButton!
    @IBOutlet weak var teacherResultSelector: NSPopUpButton!
    @IBOutlet weak var teacherDetail: NSButton!
    @IBOutlet weak var teacherLabel: NSTextField!
    
    @IBOutlet weak var classNameCombo: NSComboBox!
    @IBOutlet weak var classNameLabel: NSTextField!
    @IBOutlet weak var classNameResultSelector: NSPopUpButton!
    @IBOutlet weak var classroomDetail: NSButton!
    @IBOutlet weak var tableView: NSTabView!
    
    @IBOutlet weak var exactMatchChecker: NSButton!
    
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
        setLayoutType(.shrink)
    }
    
    @IBAction func termPopTapped(_ sender: NSPopUpButton) {
        setLayoutType(.shrink)
        if sender.selectedItem?.title == "夏季小学期" {
            setWeekPop(start: 19, end: 22)
        } else {
            setWeekPop(start: 1, end: 16)
        }
    }
    
    func getJson() {
        var jsonHead: String = ""
        if shouldRequestBeta {
            jsonHead = betaJsonHeader
        } else {
            jsonHead = stableJsonHeader
        }
        let jsonUrl = "\(jsonHead)\(yearSelector.selectedItem?.title.replacingOccurrences(of: "-", with: "_") ?? "__invalid__")_\(rawValueToInt((termSelector.selectedItem?.title)!)).json"
//        print(jsonUrl)
        self.sortBox.title = "\(self.yearSelector.selectedItem?.title ?? "未知") 学年\(self.termSelector.selectedItem?.title ?? " 未知学期")"
        self.progressIndicator.isHidden = false
        
        localTimeStamp = ""
        
        Alamofire.request(jsonUrl).response(completionHandler: { response in
            if response.response == nil {
                self.progressIndicator.isHidden = true
                self.yearSelector.isEnabled = true
                self.termSelector.isEnabled = true
                self.setLayoutType(.shrink)
                self.showErrorMessage(errorMsg: "未能读取 \(jsonUrl)。")
                return
            } else {
                DispatchQueue.global().async {
                    do {
                        let curricula = try JSON(data: response.data!)
                        self.localTimeStamp = curricula["generate_time"].stringValue
                        if let curArray = curricula["data"].array {
                            for curJson in curArray {
                                let cur = generateCur(curJson)
                                for classRoom in cur.getRelatedClassroom() {
                                    self.sortClassroom(classRoom)
                                }
                                if !(self.schools.contains(cur.holderSchool)) {
                                    self.schools.append(cur.holderSchool)
                                }
                                if !(self.teachers.contains(cur.teacherName)) {
                                    if cur.teacherName.sanitize() != "" {
                                        self.teachers.append(cur.teacherName)
                                    }
                                }
                                if !(self.classnames.contains(cur.name)) {
                                    if cur.name.sanitize() != "" {
                                        self.classnames.append(cur.name)
                                    }
                                }
                                if !(self.titles.contains(cur.teacherTitle)) {
                                    if sanitize(cur.teacherTitle) != "" {
                                        self.titles.append(cur.teacherTitle)
                                    }
                                }
                                self.courses.append(cur)
                            }
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.setLayoutType(.shrink)
                            self.showErrorMessage(errorMsg: "未能读取 \(jsonUrl)。")
                            self.progressIndicator.isHidden = true
                            self.yearSelector.isEnabled = true
                            self.termSelector.isEnabled = true
                            
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        self.progressIndicator.isHidden = true
                        self.sortLists()
                        self.pushPopListData(self.buildingSelector)
                        self.setComboSource()
                        self.startTeacherQuery()
                        self.startNameQuery()
                        self.switchSeg(self.tabTitleSeg)
                        self.updateEnableStat()
                        // success!
                        self.setEnableStats([true, true])
                        self.yearSelector.isEnabled = true
                        self.termSelector.isEnabled = true
                    }
                }
            }
        })
    }
    
    func updateEnableStat() {
        toggleUpperHall = upperHall != []
        toggleMiddleHall = middleHall != []
        toggleLowerHall = middleHall != []
        toggleEastLowerHall = eastLowerHall != []
        toggleEastMiddleHall = eastMiddleHall != []
        toggleEastUpperHall = eastUpperHall != []
        toggleCRQBuilding = CRQBuilding != []
        toggleYYMBuilding = YYMBuilding != []
        toggleMinHangCampus = MinHangCampus != []
        toggleXuHuiCampus = XuHuiCampus != []
        toggleLuWanCampus = LuWanCampus != []
        toggleFaHuaCampus = FaHuaCampus != []
        toggleQiBaoCampus = QiBaoCampus != []
        toggleLinGangCampus = LinGangCampus != []
        toggleSMHC = SMHC != []
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
        case "闵行校区陈瑞球楼"?:
            roomSelector.addRoomItems(withTitles: CRQBuilding)
            break
        case "闵行校区杨咏曼楼"?:
            roomSelector.addRoomItems(withTitles: YYMBuilding)
            break
        case "其余闵行校区教学楼"?:
            roomSelector.addRoomItems(withTitles: MinHangCampus)
            break
        case "徐汇校区"?:
            roomSelector.addRoomItems(withTitles: XuHuiCampus)
            break
        case "卢湾校区"?:
            roomSelector.addRoomItems(withTitles: LuWanCampus)
            break
        case "法华校区"?:
            roomSelector.addRoomItems(withTitles: FaHuaCampus)
            break
        case "七宝校区"?:
            roomSelector.addRoomItems(withTitles: QiBaoCampus)
            break
        case "外地"?:
            roomSelector.addRoomItems(withTitles: OtherLand)
            break
        case "上海市精神卫生中心"?:
            roomSelector.addRoomItems(withTitles: SMHC)
            break
        case "临港校区"?:
            roomSelector.addRoomItems(withTitles: LinGangCampus)
            break
        default:
            roomSelector.addItem(withTitle: "ˊ_>ˋ")
        }
        updateBoxes(sender)
    }
    
    
    @IBAction func updateQuery(_ sender: Any) {
        startTeacherQuery()
    }
    

    @IBAction func updateNameQuery(_ sender: Any) {
        startNameQuery()
    }
    
    func setComboSource() {
        self.holdingSchoolSelector.removeAllItems()
        self.holdingSchoolSelector.addItem(withTitle: "不限")
        self.holdingSchoolSelector.addItem(withTitle: "MY_MENU_SEPARATOR")
        self.holdingSchoolSelector.addItems(withTitles: schools)
        
        self.teacherNameCombo.removeAllItems()
        self.teacherNameCombo.addItems(withObjectValues: teachers.sorted().reversed())
        
        self.titleSelector.removeAllItems()
        self.titleSelector.addItem(withTitle: "不限")
        self.titleSelector.addItem(withTitle: "MY_MENU_SEPARATOR")
        self.titleSelector.addItems(withTitles: titles)
        self.teacherLabel.stringValue = "请确定筛选条件。"
        
        self.classNameResultSelector.removeAllItems()
        self.classNameLabel.stringValue = "请确定筛选条件。"
        
        self.classNameCombo.removeAllItems()
        self.classNameCombo.addItems(withObjectValues: classnames)
    }

    func startTeacherQuery() {
        queryCoursesOnTeacher.removeAll()
        teacherResultSelector.removeAllItems()
        
        var limitSchool = holdingSchoolSelector.title
        if limitSchool == "不限" {
            limitSchool = ""
        }
        
        var limitTitle = titleSelector.title
        if limitTitle == "不限" {
            limitTitle = ""
        }
        
        let teacherName = sanitize(teacherNameCombo.stringValue)
        
        if teacherName == "" {
            teacherLabel.stringValue = "请确定筛选条件。"
            teacherResultSelector.isEnabled = false
            teacherDetail.isEnabled = false
            return
        }
        
        for cur in courses {
            if exactMatchChecker.state == .off {
                if !cur.teacherName.contains(teacherName) {
                    continue
                }
            } else {
                if cur.teacherName != teacherName {
                    continue
                }
            }
            
            if limitTitle != "" {
                if cur.teacherTitle != limitTitle {
                    continue
                }
            }
            
            if limitSchool != "" {
                if cur.holderSchool != limitSchool {
                    continue
                }
            }
            
            queryCoursesOnTeacher.append(cur)
            teacherResultSelector.addItem(withTitle: "\(cur.name)，\(cur.teacherName) \(cur.teacherTitle)")
        }
        if queryCoursesOnTeacher.count == 0 {
            teacherLabel.stringValue = "没有符合条件的结果。"
            teacherResultSelector.isEnabled = false
            teacherDetail.isEnabled = false
            return
        }
        
        teacherResultSelector.isEnabled = true
        teacherDetail.isEnabled = true
        teacherLabel.stringValue = "匹配到 \(teacherResultSelector.numberOfItems) 条课程信息。"
    }
    
    func startNameQuery() {
        
        queryCoursesOnName.removeAll()
        classNameResultSelector.removeAllItems()
        let courseName = sanitize(classNameCombo.stringValue)
        if courseName == "" {
            classNameLabel.stringValue = "请确定筛选条件。"
            classNameResultSelector.isEnabled = false
            classroomDetail.isEnabled = false
            return
        }
        
        for cur in courses {
            if !cur.name.contains(courseName) {
                continue
            }
            queryCoursesOnName.append(cur)
            classNameResultSelector.addItem(withTitle: "\(cur.name)，\(cur.teacherName) \(cur.teacherTitle)")
        }
        if queryCoursesOnName.count == 0 {
            classNameLabel.stringValue = "没有符合条件的结果。"
            classNameResultSelector.isEnabled = false
            classroomDetail.isEnabled = false
            return
        }
        classNameResultSelector.isEnabled = true
        classroomDetail.isEnabled = true
        classNameLabel.stringValue = "匹配到 \(classNameResultSelector.numberOfItems) 条课程信息。"
    }
    
    func sortClassroom(_ str: String) {
        let numbersInStr = str.removeFloorCharacters(true)
        let str = str.replacingOccurrences(of: numbersInStr, with: " " + numbersInStr)
        if str.sanitize() == "" {
            return
        }
        if str.sanitize().count <= 2 {
            return
        }
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
        } else if str.contains("陈瑞球楼") {
            if !CRQBuilding.contains(str) {
                CRQBuilding.append(str)
            }
        } else if str.contains("杨咏曼楼") {
            if !YYMBuilding.contains(str) {
                YYMBuilding.append(str)
            }
        } else if str.contains("徐汇") || str.contains("新上院") || str.contains("教一楼") {
            if !XuHuiCampus.contains(str) {
                XuHuiCampus.append(str)
            }
        } else if str.contains("卢湾") {
            if !LuWanCampus.contains(str) {
                LuWanCampus.append(str)
            }
        } else if str.contains("法华") {
            if !FaHuaCampus.contains(str) {
                FaHuaCampus.append(str)
            }
        } else if str.contains("七宝") {
            if !QiBaoCampus.contains(str) {
                QiBaoCampus.append(str)
            }
        } else if str.contains("外地") {
            if !OtherLand.contains(str) {
                OtherLand.append(str)
            }
        } else if str.contains("上海市精神卫生中心") {
            if !SMHC.contains(str) {
                SMHC.append(str)
            }
        } else if str.contains("临港") {
            if !LinGangCampus.contains(str) {
                LinGangCampus.append(str)
            }
        } else {
            if !MinHangCampus.contains(str) {
                MinHangCampus.append(str)
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
        CRQBuilding.sort()
        XuHuiCampus.sort()
        LuWanCampus.sort()
        FaHuaCampus.sort()
        QiBaoCampus.sort()
        OtherLand.sort()
        SMHC.sort()
        LinGangCampus.sort()
        YYMBuilding.sort()
        MinHangCampus.sort()
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
        var description: String = ""
        if population == -1 {
            color = getColor(name: "empty")
            description = "空教室"
        } else if population < 25 {
            color = getColor(name: "light")
            description = "没什么人"
        } else if population < 50 {
            color = getColor(name: "medium")
            description = "有点人"
        } else if population < 100 {
            color = getColor(name: "heavy")
            description = "人很多"
        } else {
            color = getColor(name: "full")
            description = "人满"
        }
        let colorBox = NSImage(color: color!, size: NSSize(width: 25, height: 25))
        switch id {
        case 1:
            oneButton.image = colorBox
            oneButton.alternateTitle = "第一节课：" + description
            break
        case 2:
            twoButton.image = colorBox
            twoButton.alternateTitle = "第二节课：" + description
            break
        case 3:
            threeButton.image = colorBox
            threeButton.alternateTitle = "第三节课：" + description
            break
        case 4:
            fourButton.image = colorBox
            fourButton.alternateTitle = "第四节课：" + description
            break
        case 5:
            fiveButton.image = colorBox
            fiveButton.alternateTitle = "第五节课：" + description
            break
        case 6:
            sixButton.image = colorBox
            sixButton.alternateTitle = "第六节课：" + description
            break
        case 7:
            sevenButton.image = colorBox
            sevenButton.alternateTitle = "第七节课：" + description
            break
        case 8:
            eightButton.image = colorBox
            eightButton.alternateTitle = "第八节课：" + description
            break
        case 9:
            nineButton.image = colorBox
            nineButton.alternateTitle = "第九节课：" + description
            break
        case 10:
            tenButton.image = colorBox
            tenButton.alternateTitle = "第十节课：" + description
            break
        case 11:
            elevenButton.image = colorBox
            elevenButton.alternateTitle = "第十一节课：" + description
            break
        case 12:
            twelveButton.image = colorBox
            twelveButton.alternateTitle = "第十二节课：" + description
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
    
    static let layoutTable: [NSSize] = [
        NSSize(width: 504, height: 79 + toolBarHeight),
        NSSize(width: 536, height: 363 + 30 + toolBarHeight),
        NSSize(width: 504, height: 290 + 30 + toolBarHeight),
        NSSize(width: 556, height: 242 + 30 + toolBarHeight)
        ]
    
    func setLayoutType(_ type: LayoutType) {
        self.tableView.alphaValue = 0.0
//        let frame = self.view.window?.frame
//        if frame != nil {
//            let heightDelta = frame!.size.height - FullDataViewController.layoutTable[type.rawValue].height
//            let origin = NSMakePoint(frame!.origin.x, frame!.origin.y + heightDelta)
//            let size = FullDataViewController.layoutTable[type.rawValue]
//            let newFrame = NSRect(origin: origin, size: size)
//            self.view.window?.setFrame(newFrame, display: true, animate: true)
            NSAnimationContext.runAnimationGroup({ (context) in
                self.tableView.animator().alphaValue = 1.0
            }, completionHandler: nil)
//        }
        if type == .shrink {
            setEnableStats([true, false])
        }
    }
    
    func displayDetail(_ classes: [Curricula]) {
        for i in classes {
            NSLog(i.identifier)
        }
        let className = classes[0].name
        let teacher = classes[0].teacherName + " " + classes[0].teacherTitle
        let holder = classes[0].holderSchool
        
        var declare = ""
        
            for cur in classes {
                var target = "课程 ID：\(cur.identifier)\n"
                if cur.targetGrade != 0 {
                    target += "\t面向 \(cur.targetGrade) 级学生\n"
                }
                if cur.notes != "" {
                    target += "附注：\(cur.notes)\n"
                }
                var schedule = "\t第 \(cur.startWeek) 至第 \(cur.endWeek) 周"
                let both = "每周上课，\n"
                let odd = "之中的单周：\n"
                let even = "\t双周：\n"
                var tag = ""
                if cur.isContinuous() {
                    tag += both
                    for arr in cur.oddWeekArr {
                        tag += "\t\t\(dayOfWeekName[arr.weekDay])第 \(arr.startsAt) ~ \(arr.endsAt) 节，在\(arr.classroom)\n"
                    }
                } else {
                    tag += odd
                    for arr in cur.oddWeekArr {
                        tag += "\t\t\(dayOfWeekName[arr.weekDay])第 \(arr.startsAt) ~ \(arr.endsAt) 节，在\(arr.classroom)\n"
                    }
                    tag += even
                    for arr in cur.evenWeekArr {
                        tag += "\t\t\(dayOfWeekName[arr.weekDay])第 \(arr.startsAt) ~ \(arr.endsAt) 节，在\(arr.classroom)\n"
                    }
                }
                schedule += tag
                target += schedule
                declare += target + "\n"
            }
        declare.removeLast()
        
        let infoAlert: NSAlert = NSAlert()
        infoAlert.messageText = className
        infoAlert.informativeText = "教师：\(teacher)\n开课院系：\(holder)\n\n\(declare)"
        infoAlert.addButton(withTitle: "嗯")
        infoAlert.alertStyle = NSAlert.Style.informational
        infoAlert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
    
    @IBAction func switchSeg(_ sender: NSSegmentedControl) {
        tableView.selectTabViewItem(at: sender.selectedSegment)
        if sender.selectedSegment == 0 {
            setLayoutType(.classroom)
        } else if sender.selectedSegment == 1 {
            setLayoutType(.teacher)
        } else if sender.selectedSegment == 2 {
            setLayoutType(.name)
        }
    }
    @IBAction func byNameDetail(_ sender: NSButton) {
        let array = classNameResultSelector.titleOfSelectedItem?.replacingOccurrences(of: "，", with: " ").components(separatedBy: " ")
        if array?.count != 3 {
            return
        }
        var target: [Curricula] = []
        for cur in queryCoursesOnName {
            if cur.name != array![0] {
                continue
            }
            if cur.teacherName != array![1] {
                continue
            }
            if cur.teacherTitle != array![2] {
                continue
            }
            target.append(cur)
        }
        displayDetail(target)
    }
    
    @IBAction func detailByTeacher(_ sender: NSButton) {
        let array = teacherResultSelector.titleOfSelectedItem?.replacingOccurrences(of: "，", with: " ").components(separatedBy: " ")
        if array?.count != 3 {
            return
        }
        var target: [Curricula] = []
        for cur in queryCoursesOnTeacher {
            if cur.name != array![0] {
                continue
            }
            if cur.teacherName != array![1] {
                continue
            }
            if cur.teacherTitle != array![2] {
                continue
            }
            target.append(cur)
        }
        displayDetail(target)
    }
    
    func showDataInfo() {
        if localTimeStamp != "" {
            let infoAlert: NSAlert = NSAlert()
            infoAlert.messageText = "数据详情"
            if shouldRequestBeta {
                infoAlert.informativeText = "(Beta 数据)\n\n"
            }
            infoAlert.informativeText += "生成时间：\(localTimeStamp) (GMT+08:00)\n数据量：\(courses.count)"
            infoAlert.addButton(withTitle: "嗯")
            infoAlert.alertStyle = NSAlert.Style.informational
            infoAlert.beginSheetModal(for: self.view.window!, completionHandler: nil)
        } else {
            let infoAlert: NSAlert = NSAlert()
            infoAlert.messageText = "数据详情"
            infoAlert.informativeText = "生成时间：未知\n数据量：\(courses.count)"
            infoAlert.addButton(withTitle: "嗯")
            infoAlert.alertStyle = NSAlert.Style.informational
            infoAlert.beginSheetModal(for: self.view.window!, completionHandler: nil)
        }
    }
    
    @IBAction func getTimeStamp(_ sender: NSButton) {
        showDataInfo()
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
        var lastBuilding: String?
        for item in items {
            let analyseItem = item.sanitize()
            if item.contains("校区") {
                continue
            }
            let curIndex: Int? = Int(analyseItem.removeFloorCharacters().prefix(1))
            let numericStr = analyseItem.removeFloorCharacters(true)
            let curBuilding: String? = analyseItem.deleteOccur(remove: numericStr)
            if (curIndex != nil) {
//            print("cur: \(curIndex), last: \(lastIndex)")
                if (lastIndex != nil) && (lastBuilding != nil) {
                    if (curIndex! != lastIndex) || (curBuilding != lastBuilding) {
                        lastIndex = curIndex!
                        lastBuilding = curBuilding!
    //                    print("should add sep")
                        self.addItem(withTitle: "MY_MENU_SEPARATOR")
                    }
                } else {
                    lastIndex = curIndex
                    lastBuilding = curBuilding
                }
                self.addItem(withTitle: item)
            } else {
                 self.addItem(withTitle: item)
            }
        }
    }
}


enum LayoutType: Int {
    case shrink = 0
    case classroom = 1
    case teacher = 2
    case name = 3
}


