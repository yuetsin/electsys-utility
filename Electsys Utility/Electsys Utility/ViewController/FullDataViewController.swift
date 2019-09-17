//
//  FullDataViewController.swift
//  Sync Utility
//
//  Created by yuxiqian on 2018/9/5.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Alamofire
import Cocoa
import Regex
import SwiftyJSON

class FullDataViewController: NSViewController {
    static let toolBarHeight = 56

    let specialSep = "$_$"

    var shouldRequestBeta: Bool = false

    var courses: [NGCurriculum] = []

    var queryCoursesOnTeacher: [NGCurriculum] = []
    var queryCoursesOnName: [NGCurriculum] = []

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

    var possibleUrl: String = "未知"

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
        let date = Date()
        let calendar = Calendar.current
        var year = calendar.component(.year, from: date)

        tabTitleSeg.isEnabled = false
        showMoreButton.isEnabled = false
        tableView.selectTabViewItem(at: 3)

        yearSelector.removeAllItems()

        if year < 2019 {
            year = 2019
            // fallback as year 2019
        }

        if year < 2018 {
            return
        }

        for iteratedYear in (2018 ... year).reversed() {
            yearSelector.addItem(withTitle: "\(iteratedYear) 至 \(iteratedYear + 1) 学年")
        }
    }

    func setEnableStats(_ stat: [Bool]) {
        betaSelector.isEnabled = stat[0]
        showMoreButton.isEnabled = stat[1]
    }

    func setWeekPop(start: Int, end: Int) {
        weekSelector.removeAllItems()
        for i in start ... end {
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

    @IBOutlet var yearSelector: NSPopUpButton!
    @IBOutlet var termSelector: NSPopUpButton!
    @IBOutlet var progressIndicator: NSProgressIndicator!
    @IBOutlet var buildingSelector: NSPopUpButton!
    @IBOutlet var roomSelector: NSPopUpButton!
    @IBOutlet var weekDaySelector: NSPopUpButton!

    @IBOutlet var weekSelector: NSPopUpButton!

    @IBOutlet var oneButton: NSButton!
    @IBOutlet var twoButton: NSButton!
    @IBOutlet var threeButton: NSButton!
    @IBOutlet var fourButton: NSButton!
    @IBOutlet var fiveButton: NSButton!
    @IBOutlet var sixButton: NSButton!
    @IBOutlet var sevenButton: NSButton!
    @IBOutlet var eightButton: NSButton!
    @IBOutlet var nineButton: NSButton!
    @IBOutlet var tenButton: NSButton!
    @IBOutlet var elevenButton: NSButton!
    @IBOutlet var twelveButton: NSButton!

    @IBOutlet var tabTitleSeg: NSSegmentedControl!
    @IBOutlet var sortBox: NSBox!
    @IBOutlet var detailBox: NSBox!

    @IBOutlet var holdingSchoolSelector: NSPopUpButton!
    @IBOutlet var teacherNameCombo: NSComboBox!
    @IBOutlet var titleSelector: NSPopUpButton!
    @IBOutlet var teacherResultSelector: NSPopUpButton!
    @IBOutlet var teacherDetail: NSButton!
    @IBOutlet var teacherLabel: NSTextField!

    @IBOutlet var classNameCombo: NSComboBox!
    @IBOutlet var classNameLabel: NSTextField!
    @IBOutlet var classNameResultSelector: NSPopUpButton!
    @IBOutlet var classroomDetail: NSButton!
    @IBOutlet var tableView: NSTabView!

    @IBOutlet var betaSelector: NSButton!
    @IBOutlet var showMoreButton: NSButton!
    @IBOutlet var exactMatchChecker: NSButton!

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

    @IBAction func betaTapped(_ sender: NSButton) {
        setLayoutType(.shrink)
        shouldRequestBeta = (sender.state == .on)
    }

    @IBAction func termPopTapped(_ sender: NSPopUpButton) {
        setLayoutType(.shrink)
        if sender.selectedItem?.title == "夏季小学期" {
            setWeekPop(start: 1, end: 5)
        } else {
            setWeekPop(start: 1, end: 17)
        }
    }

    func getJson() {
        if yearSelector.titleOfSelectedItem == nil {
            showErrorMessage(errorMsg: "请完整地填写所有信息。")
            return
        }
        let yearInt = Int(yearSelector.titleOfSelectedItem!.components(separatedBy: " 至 ").first ?? "2019") ?? 2019
//        print(jsonUrl)
        let termInt = termSelector.indexOfSelectedItem + 1

        sortBox.title = "\(yearSelector.selectedItem?.title ?? "未知") 学年\(termSelector.selectedItem?.title ?? " 未知学期")"
        progressIndicator.isHidden = false

        let useBeta = betaSelector.state == .on

        possibleUrl = GalleryKits.possibleUrl ?? "未知"
        DispatchQueue.global().async {
            GalleryKits.requestGalleryData(year: yearInt,
                                           term: termInt,
                                           beta: useBeta,
                                           handler: { courseResult, timeStamp in
                                               self.courses = courseResult
                                               self.aggregateData()
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
                                                   self.localTimeStamp = timeStamp
                                               }
                                           },
                                           failure: { code in
                                               DispatchQueue.main.async {
                                                   self.progressIndicator.isHidden = true
                                                   self.yearSelector.isEnabled = true
                                                   self.termSelector.isEnabled = true
                                                   self.setLayoutType(.shrink)
                                                   self.showErrorMessage(errorMsg: "未能读取此学期的数据。\n错误代码：\(code)")
                                               }
            })
        }
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
        holdingSchoolSelector.removeAllItems()
        holdingSchoolSelector.addItem(withTitle: "不限")
        holdingSchoolSelector.addItem(withTitle: "MY_MENU_SEPARATOR")
        holdingSchoolSelector.addItems(withTitles: schools)

        teacherNameCombo.removeAllItems()
        teacherNameCombo.addItems(withObjectValues: teachers.sorted().reversed())

        titleSelector.removeAllItems()
        titleSelector.addItem(withTitle: "不限")
        titleSelector.addItem(withTitle: "MY_MENU_SEPARATOR")
        titleSelector.addItems(withTitles: titles)
        teacherLabel.stringValue = "请确定筛选条件。"

        classNameResultSelector.removeAllItems()
        classNameLabel.stringValue = "请确定筛选条件。"

        classNameCombo.removeAllItems()
        classNameCombo.addItems(withObjectValues: classnames)
    }

    func startTeacherQuery() {
        PreferenceKits.readPreferences()

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
            for teacherNameLiteral in cur.teacher {
                if exactMatchChecker.state == .off {
                    if !teacherNameLiteral.contains(teacherName) {
                        continue
                    }
                } else {
                    if teacherNameLiteral != teacherName {
                        continue
                    }
                }

                if limitSchool != "" {
                    if cur.holderSchool != limitSchool {
                        continue
                    }
                }

                queryCoursesOnTeacher.append(cur)

                if PreferenceKits.courseDisplayStrategy == .nameOnly {
                    teacherResultSelector.addItem(withTitle: "\(cur.name)")
                } else if PreferenceKits.courseDisplayStrategy == .nameAndTeacher {
                    teacherResultSelector.addItem(withTitle: "\(cur.name)，\(cur.teacher.joined(separator: "、"))")
                } else if PreferenceKits.courseDisplayStrategy == .codeNameAndTeacher {
                    teacherResultSelector.addItem(withTitle: "\(cur.code) - \(cur.name)，\(cur.teacher.joined(separator: "、"))")
                }
            }
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
            if PreferenceKits.courseDisplayStrategy == .nameOnly {
                classNameResultSelector.addItem(withTitle: "\(cur.name)")
            } else if PreferenceKits.courseDisplayStrategy == .nameAndTeacher {
                classNameResultSelector.addItem(withTitle: "\(cur.name)，\(cur.teacher.joined(separator: "、"))")
            } else if PreferenceKits.courseDisplayStrategy == .codeNameAndTeacher {
                classNameResultSelector.addItem(withTitle: "\(cur.code) - \(cur.name)，\(cur.teacher.joined(separator: "、"))")
            }
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

    func sortClassroom(building: String, campus: String) {
        if building.contains("不排教室") || building.contains("未定") || building.contains("不安排") {
            return
        }
        let numbersInStr = building.removeFloorCharacters(true)
        let str = building.replacingOccurrences(of: numbersInStr, with: " " + numbersInStr)
        if str.sanitize() == "" {
            return
        }

        if str.sanitize().count <= 2 {
            return
        }

        if campus == "闵行" {
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
            } else {
                if !MinHangCampus.contains(str) {
                    MinHangCampus.append(str)
                }
            }
        } else if campus == "徐汇" {
            if !XuHuiCampus.contains(str) {
                XuHuiCampus.append(str)
            }
        } else if campus == "卢湾" {
            if !LuWanCampus.contains(str) {
                LuWanCampus.append(str)
            }
        } else if campus == "法华" {
            if !FaHuaCampus.contains(str) {
                FaHuaCampus.append(str)
            }
        } else if campus == "七宝" {
            if !QiBaoCampus.contains(str) {
                QiBaoCampus.append(str)
            }
        } else if campus == "外地" {
            if !OtherLand.contains(str) {
                OtherLand.append(str)
            }
        } else if campus == "上海市精神卫生中心" {
            if !SMHC.contains(str) {
                SMHC.append(str)
            }
        } else if campus == "临港" {
            if !LinGangCampus.contains(str) {
                LinGangCampus.append(str)
            }
        } else {
            NSLog("uncategorized: \(campus), \(building)")
        }
    }

    func showErrorMessage(errorMsg: String) {
        if view.window == nil {
            return
        }
        let errorAlert: NSAlert = NSAlert()
        errorAlert.messageText = "出错啦"
        errorAlert.informativeText = errorMsg
        errorAlert.addButton(withTitle: "嗯")
        errorAlert.alertStyle = NSAlert.Style.critical
        errorAlert.beginSheetModal(for: view.window!, completionHandler: nil)
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
        for i in 1 ... 12 {
            drawBox(id: i)
        }
        arrangement = [String].init(repeating: "空教室", count: 14)

        let currentWeek = hanToInt(weekSelector.selectedItem?.title)
//        let weekDay = dayToInt.firstIndex(of: (weekDaySelector.selectedItem?.title)!)
        detailBox.title = "\(roomSelector.selectedItem?.title ?? "某教室")，\(weekSelector.selectedItem?.title ?? "某周")\(weekDaySelector.selectedItem?.title ?? "某日")教室安排情况"

        if let room = self.roomSelector.selectedItem?.title.sanitize() {
            for cur in courses {
                for arr in cur.arrangements {
                    if !arr.weeks.contains(currentWeek) {
                        // 非本周
                        continue
                    }

                    if !arr.classroom.contains(room) {
                        continue
                    }

                    for lessonIndex in arr.sessions {
                        drawBox(id: lessonIndex, population: cur.studentNumber)
                        arrangement[lessonIndex - 1] = "\(cur.name)\(specialSep)开课院系：\(cur.holderSchool)\n教师：\(cur.teacher.joined(separator: "、"))\n人数：\(cur.studentNumber)"
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
            oneButton.setAccessibilityLabel("第一节课：" + description)
            break
        case 2:
            twoButton.image = colorBox
            twoButton.setAccessibilityLabel("第二节课：" + description)
            break
        case 3:
            threeButton.image = colorBox
            threeButton.setAccessibilityLabel("第三节课：" + description)
            break
        case 4:
            fourButton.image = colorBox
            fourButton.setAccessibilityLabel("第四节课：" + description)
            break
        case 5:
            fiveButton.image = colorBox
            fiveButton.setAccessibilityLabel("第五节课：" + description)
            break
        case 6:
            sixButton.image = colorBox
            sixButton.setAccessibilityLabel("第六节课：" + description)
            break
        case 7:
            sevenButton.image = colorBox
            sevenButton.setAccessibilityLabel("第七节课：" + description)
            break
        case 8:
            eightButton.image = colorBox
            eightButton.setAccessibilityLabel("第八节课：" + description)
            break
        case 9:
            nineButton.image = colorBox
            nineButton.setAccessibilityLabel("第九节课：" + description)
            break
        case 10:
            tenButton.image = colorBox
            tenButton.setAccessibilityLabel("第十节课：" + description)
            break
        case 11:
            elevenButton.image = colorBox
            elevenButton.setAccessibilityLabel("第十一节课：" + description)
            break
        case 12:
            twelveButton.image = colorBox
            twelveButton.setAccessibilityLabel("第十二节课：" + description)
            break
        default:
            break
        }
    }

    func showCourseInfo(titleMsg: String, infoMsg: String) {
        if view.window == nil {
            return
        }
        let infoAlert: NSAlert = NSAlert()
        infoAlert.messageText = titleMsg
        infoAlert.informativeText = infoMsg
        infoAlert.addButton(withTitle: "嗯")
        infoAlert.alertStyle = NSAlert.Style.informational
        infoAlert.beginSheetModal(for: view.window!, completionHandler: nil)
    }

    static let layoutTable: [NSSize] = [
        NSSize(width: 504, height: 79 + toolBarHeight),
        NSSize(width: 536, height: 363 + 30 + toolBarHeight),
        NSSize(width: 504, height: 290 + 30 + toolBarHeight),
        NSSize(width: 556, height: 242 + 30 + toolBarHeight),
    ]

    func setLayoutType(_ type: LayoutType) {
//        self.tableView.alphaValue = 0.0
//        let frame = self.view.window?.frame
//        if frame != nil {
//            let heightDelta = frame!.size.height - FullDataViewController.layoutTable[type.rawValue].height
//            let origin = NSMakePoint(frame!.origin.x, frame!.origin.y + heightDelta)
//            let size = FullDataViewController.layoutTable[type.rawValue]
//            let newFrame = NSRect(origin: origin, size: size)
//            self.view.window?.setFrame(newFrame, display: true, animate: true)
//            NSAnimationContext.runAnimationGroup({ (context) in
//                self.tableView.animator().alphaValue = 1.0
//            }, completionHandler: nil)
        ////        }
        if type == .shrink {
            setEnableStats([true, false])
            tableView.selectTabViewItem(at: 3)
            tabTitleSeg.isEnabled = false
            showMoreButton.isEnabled = false
        } else {
            tabTitleSeg.isEnabled = true
            showMoreButton.isEnabled = true
            tableView.selectTabViewItem(at: tabTitleSeg.selectedSegment)
        }
    }

    func displayDetail(_ classes: [NGCurriculum]) {
        for i in classes {
            NSLog(i.identifier)
        }
        let className = classes[0].name
        let teacher = classes[0].teacher.joined(separator: "、")
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
            for arrange in cur.arrangements {
                target += "\(arrange.getWeeksInterpreter())\n\(dayOfWeekName[arrange.weekDay])\(arrange.getSessionsInterpreter())\n\(arrange.campus)校区 \(arrange.classroom)\n\n"
            }
            declare += target
        }
        declare.removeLast()

        let infoAlert: NSAlert = NSAlert()
        infoAlert.messageText = className
        infoAlert.informativeText = "教师：\(teacher)\n开课院系：\(holder)\n\n\(declare)"
        infoAlert.addButton(withTitle: "嗯")
        infoAlert.alertStyle = NSAlert.Style.informational
        if view.window == nil {
            return
        }
        infoAlert.beginSheetModal(for: view.window!, completionHandler: nil)
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
        var target: [NGCurriculum] = []
        for cur in queryCoursesOnName {
            if cur.name != array![0] {
                continue
            }
            if !cur.teacher.contains(array![1]) {
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
        var target: [NGCurriculum] = []
        for cur in queryCoursesOnTeacher {
            if cur.name != array![0] {
                continue
            }
            if !cur.teacher.contains(array![1]) {
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
            infoAlert.informativeText += "来源：\(possibleUrl)\n\n生成时间：\(localTimeStamp) (GMT+08:00)\n数据量：\(courses.count)"
            infoAlert.addButton(withTitle: "嗯")
            infoAlert.alertStyle = NSAlert.Style.informational
            if view.window == nil {
                return
            }
            infoAlert.beginSheetModal(for: view.window!, completionHandler: nil)
        } else {
            let infoAlert: NSAlert = NSAlert()
            infoAlert.messageText = "数据详情"
            infoAlert.informativeText = "来源：\(possibleUrl)\n\n生成时间：未知\n数据量：\(courses.count)"
            infoAlert.addButton(withTitle: "嗯")
            infoAlert.alertStyle = NSAlert.Style.informational
            if view.window == nil {
                return
            }
            infoAlert.beginSheetModal(for: view.window!, completionHandler: nil)
        }
    }

    func aggregateData() {
        for cur in courses {
            for related in cur.getRelated() {
                sortClassroom(building: related.strA, campus: related.strB)
            }

            if !schools.contains(cur.holderSchool) {
                schools.append(cur.holderSchool)
            }
            for teacherName in cur.teacher {
                if !teachers.contains(teacherName) {
                    if teacherName.sanitize() != "" {
                        teachers.append(teacherName)
                    }
                }
            }

            if !classnames.contains(cur.name) {
                if cur.name.sanitize() != "" {
                    classnames.append(cur.name)
                }
            }
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
        draw(in: NSRect(origin: .zero, size: size),
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
            if curIndex != nil {
//            print("cur: \(curIndex), last: \(lastIndex)")
                if (lastIndex != nil) && (lastBuilding != nil) {
                    if (curIndex! != lastIndex) || (curBuilding != lastBuilding) {
                        lastIndex = curIndex!
                        lastBuilding = curBuilding!
                        //                    print("should add sep")
                        addItem(withTitle: "MY_MENU_SEPARATOR")
                    }
                } else {
                    lastIndex = curIndex
                    lastBuilding = curBuilding
                }
                addItem(withTitle: item)
            } else {
                addItem(withTitle: item)
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
