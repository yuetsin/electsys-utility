//
//  ResolveViewController.swift
//  Sync Utility
//
//  Created by yuxiqian on 2018/8/31.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Cocoa
import EventKit

@available(OSX 10.12.2, *)
class ResolveViewController: NSViewController, writeCalendarDelegate, YearAndTermSelectionDelegate {
    
    @IBOutlet weak var resolveTBButton: NSButton!
    
    @IBAction func resolveAnotherTerm(_ sender: NSButton) {
        restartAnalyse(sender)
    }
    
    func successCourseDataTransfer(data: [NGCourse]) {
        courseList = data
        updatePopUpSelector()
        self.dismiss(sheetViewController)
    }

    func successExamDataTransfer(data: [NGExam]) {
        NSLog("bad request type")
        self.dismiss(sheetViewController)
    }

    func successScoreDataTransfer(data: [NGScore]) {
        NSLog("bad request type")
        self.dismiss(sheetViewController)
    }
    
    func shutWindow() {
        self.dismiss(sheetViewController)
    }

    override func viewDidLoad() {
        updatePopUpSelector()
        startWeekSelector.dateValue = Date()
        onDatePicked(startWeekSelector)
        loadingRing.startAnimation(self)
        loadingTextField.stringValue = ""
//        courseIdentifierField.isEnabled = false
//        courseScoreField.isEnabled = false
//        courseTimeField.isEnabled = false
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        if courseList.count == 0 {
            openYearTermSelectionPanel()
        }
        
        PreferenceKits.readPreferences()
        if PreferenceKits.hidePersonalInfo {
            showPersonalInfoButton.isHidden = true
        } else {
            showPersonalInfoButton.isHidden = false
        }
    }


    func openYearTermSelectionPanel() {
        sheetViewController.successDelegate = self
        sheetViewController.requestType = .course
        self.presentAsSheet(sheetViewController)
        sheetViewController.enableUI()
    }
    
    lazy var sheetViewController: TermSelectingViewController = {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        return storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("YearAndTermViewController"))
        as! TermSelectingViewController
    }()


    var htmlDoc: String = ""
    var courseList: [NGCourse] = []

    var startDate: Date?
    var inputCounter: Int = 0
    var expectedCounter: Int = 0
    var calendarHelper: CalendarHelper?
    var remindState: remindType = .fifteenMinutes

    @IBOutlet var coursePopUpList: NSPopUpButton!
    @IBOutlet var promptTextField: NSTextField!
    @IBOutlet var willRemindBox: NSButton!
    @IBOutlet var remindTypeSelector: NSPopUpButton!
    @IBOutlet var startWeekSelector: NSDatePicker!
    @IBOutlet var startWeekIndicator: NSTextField!
    @IBOutlet var syncAccountType: NSPopUpButton!
    @IBOutlet var calendarTextField: NSTextField!
    @IBOutlet var loadingRing: NSProgressIndicator!
    @IBOutlet var relsamaHouwyButton: NSButton!
    @IBOutlet var startSyncButton: NSButton!

    @IBOutlet var courseNameField: NSTextField!
    @IBOutlet var courseRoomField: NSTextField!
    @IBOutlet var courseIdentifierField: NSTextField!
    @IBOutlet var courseScoreField: NSTextField!
    @IBOutlet var courseTimeField: NSTextField!
    @IBOutlet var loadingTextField: NSTextField!
    @IBOutlet var diceButton: NSButton!
    @IBOutlet weak var blurredView: RMBlurredView!
    @IBOutlet weak var showPersonalInfoButton: NSButton!
    @IBOutlet weak var showInspectorButton: NSButton!
    
    @IBAction func showInspector(_ sender: NSButton) {
        if coursePopUpList.indexOfSelectedItem < 0 || coursePopUpList.indexOfSelectedItem >= courseList.count {
            return
        }
        
        let courseObject = courseList[coursePopUpList.indexOfSelectedItem]
        
        var shiftWeekProperty = Property(name: "行课安排", value: "每周上课")
        if courseObject.shiftWeek == .OddWeekOnly {
            shiftWeekProperty.value = "仅单数周上课"
        } else if courseObject.shiftWeek == .EvenWeekOnly {
            shiftWeekProperty.value = "仅双数周上课"
        }
        InspectorKits.showProperties(properties: [
            Property(name: "课号", value: courseObject.courseCode),
            Property(name: "教学班 ID", value: courseObject.courseIdentifier),
            Property(name: "课名", value: courseObject.courseName),
            Property(name: "教室", value: courseObject.courseRoom),
            Property(name: "学分", value: String.init(format: "%.1f", courseObject.courseScore)),
            Property(name: "教师", value: courseObject.courseTeacher.joined(separator: "、")),
            Property(name: "教师职称", value: courseObject.courseTeacherTitle.joined(separator: "、")),
            Property(name: "上课时间", value: "\(defaultLessonTime[courseObject.dayStartsAt].getTimeString())"),
            Property(name: "下课时间", value: "\(defaultLessonTime[courseObject.dayEndsAt].getTimeString(passed: durationMinutesOfLesson))"),
            Property(name: "备注信息", value: courseObject.notes),
            Property(name: "开始周数", value: "第 \(courseObject.weekStartsAt) 周"),
            Property(name: "结束周数", value: "第 \(courseObject.weekEndsAt) 周"),
            shiftWeekProperty
        ])
    }
    
    @IBAction func showPersonalInfo(_ sender: NSButton) {
        if PreferenceKits.hidePersonalInfo {
            showErrorMessageNormal(errorMsg: "当前的安全设置不允许显示个人信息。")
            return
        }
        if IdentityKits.studentId == nil || IdentityKits.studentName == nil || IdentityKits.studentNameEn == nil {
            showErrorMessageNormal(errorMsg: "未能获取个人信息。")
            return
        }
        
        InspectorKits.showProperties(properties: [Property(name: "姓名", value: IdentityKits.studentName!),
                                                  Property(name: "英文名", value: IdentityKits.studentNameEn!),
                                                  Property(name: "学号", value: IdentityKits.studentId!)])
    }
    
    func disableUI() {
        coursePopUpList.isEnabled = false
        willRemindBox.isEnabled = false
        remindTypeSelector.isEnabled = false
        startWeekSelector.isEnabled = false
        syncAccountType.isEnabled = false
        courseNameField.isEnabled = false
        courseRoomField.isEnabled = false
        calendarTextField.isEnabled = false
        relsamaHouwyButton.isEnabled = false
        startSyncButton.isEnabled = false
        diceButton.isEnabled = false
        loadingRing.isHidden = false
        
        resolveTBButton.isHidden = true
        
    }

    func resumeUI() {
        coursePopUpList.isEnabled = true
        willRemindBox.isEnabled = true
        remindTypeSelector.isEnabled = true
        startWeekSelector.isEnabled = true
        syncAccountType.isEnabled = true
        courseNameField.isEnabled = true
        courseRoomField.isEnabled = true
        calendarTextField.isEnabled = true
        relsamaHouwyButton.isEnabled = true
        startSyncButton.isEnabled = true
        diceButton.isEnabled = true
        loadingRing.isHidden = true
        resolveTBButton.isHidden = false
        remindTapped(willRemindBox)
        updatePopUpSelector()
    }

    @IBAction func remindTapped(_ sender: NSButton) {
        if willRemindBox.state == NSControl.StateValue.on {
            remindTypeSelector.isEnabled = true
            switch remindTypeSelector.selectedItem!.title {
            case "上课前 15 分钟":
                remindState = .fifteenMinutes
                break
            case "上课前 10 分钟":
                remindState = .tenMinutes
                break
            case "上课时":
                remindState = .atCourseStarts
                break
            default:
                remindState = .noReminder
            }
        } else {
            remindTypeSelector.isEnabled = false
            remindState = .noReminder
        }
    }

    @IBAction func updateRemindState(_ sender: NSPopUpButton) {
        remindTapped(willRemindBox)
    }

    @IBAction func restartAnalyse(_ sender: NSButton) {
        loadingTextField.stringValue = ""
        courseList.removeAll()
        updatePopUpSelector()
        openYearTermSelectionPanel()
    }

    @IBAction func makeRandomName(_ sender: NSButton) {
        calendarTextField.stringValue = getRandomNames()
    }

    @IBAction func popUpClicked(_ sender: NSPopUpButton) {
        updateInfoField()
    }

    @IBAction func checkSummerBox(_ sender: NSButton) {
        onDatePicked(startWeekSelector)
        updatePopUpSelector()
    }

    @IBAction func removePiece(_ sender: NSButton) {
        if coursePopUpList.itemArray.count == 0 {
            return
        }
        let index = coursePopUpList.selectedItem?.indexIn((coursePopUpList?.itemArray)!)
        if index == nil || index == -1 {
            return
        }
        courseList.remove(at: index!)
        updatePopUpSelector()
    }

    @IBAction func saveInfo(_ sender: NSButton) {
        if coursePopUpList.itemArray.count == 0 {
            return
        }
        let index = coursePopUpList.selectedItem?.indexIn((coursePopUpList?.itemArray)!)
        if index == nil || index == -1 {
            return
        }

        courseList[index!].courseName = courseNameField.stringValue
        courseList[index!].courseRoom = courseRoomField.stringValue
        updatePopUpSelector(at: index!)
    }

    @IBAction func onDatePicked(_ sender: NSDatePicker) {
        var startDate = sender.dateValue
        while startDate.getWeekDay() > 1 {
            startDate = startDate.addingTimeInterval(-secondsInDay)
//            print("Date: \(startDate.getStringExpression()), weekday: \(startDate.getWeekDay())")
        }
        startWeekIndicator.stringValue =
            "以 \(startDate.getStringExpression())，星期一作为此学期第一周的开始。"
        
        self.startDate = startDate
    }

    //    @IBAction func addExampleEvent(_ sender: NSButton) {
    //        addToCalendar(date: self.startWeekSelector.dateValue,
    //                      title: "Example Title",
    //                      place: "Example Location",
    //                      start: defaultLessonTime[2],
    //                      end: defaultLessonTime[4],
    //                      remindType: .tenMinutes)
    //    }
    @IBAction func startSync(_ sender: NSButton) {
        if courseList.count == 0 {
            showErrorMessageNormal(errorMsg: "没有任何待同步的课表。")
            return
        }
        inputCounter = 0
        expectedCounter = 0
        print("课表的名字：\(calendarTextField.stringValue)")
        if calendarTextField.stringValue == "" {
            calendarTextField.stringValue = "jAccount 同步"
        }
        switch syncAccountType.selectedItem!.title {
        case "CalDAV 或 iCloud 日历":
            calendarHelper = CalendarHelper(name: calendarTextField.stringValue,
                                            type: .calDAV, delegate: self)
            break
        case "Mac 上的本地日历":
            calendarHelper = CalendarHelper(name: calendarTextField.stringValue,
                                            type: .local, delegate: self)
            break
        default:
            return
        }

        disableUI()

//        calendarHelper.commitChanges()
    }

    func updatePopUpSelector(at itemIndex: Int = 0) {
        coursePopUpList.removeAllItems()

        if courseList.count == 0 {
            promptTextField.stringValue = "目前没有任何课程信息。"
            view.window?.makeFirstResponder(blurredView)
            blurredView.blurRadius = 3.0
            blurredView.isHidden = false
            promptTextField.isEnabled = false
            showPersonalInfoButton.isEnabled = false
            showInspectorButton.isEnabled = false
            courseNameField.stringValue = ""
            courseRoomField.stringValue = ""
            courseIdentifierField.stringValue = ""
            courseScoreField.stringValue = ""
            courseTimeField.stringValue = ""
            return
        }
        
        showInspectorButton.isEnabled = true
        blurredView.isHidden = true
        blurredView.blurRadius = 0.0
        
        if IdentityKits.studentId == nil || IdentityKits.studentName == nil || IdentityKits.studentNameEn == nil {
            showPersonalInfoButton.isEnabled = false
        } else {
            showPersonalInfoButton.isEnabled = true
        }
        promptTextField.isEnabled = true
        promptTextField.stringValue = "现有 \(courseList.count) 条课程信息。"
        
        var counter = 1
        for course in courseList {
            coursePopUpList.addItem(withTitle: "(\(counter))" + course.getExtraIdentifier())
            counter += 1
        }

        if itemIndex != 0 {
            coursePopUpList.selectItem(at: itemIndex)
        }
        updateInfoField()
    }

    func startWriteCalendar() {
        DispatchQueue.global().async {
            for course in self.courseList {
                for week in generateArray(start: course.weekStartsAt,
                                          end: course.weekEndsAt,
                                          shift: course.shiftWeek) {
                    self.expectedCounter += 1
                    self.calendarHelper!.addToCalendar(date: self.startDate!.convertWeekToDate(week: week, weekday: course.courseDay),
                                                       title: course.generateCourseName(),
                                                       place: course.courseRoom,
                                                       start: defaultLessonTime[course.dayStartsAt],
                                                       end: defaultLessonTime[course.dayEndsAt].getTime(passed: durationMinutesOfLesson),
                                                       remindType: self.remindState)
                }
            }
        }
    }

    func updateInfoField() {
        let index = coursePopUpList.selectedItem?.indexIn((coursePopUpList?.itemArray)!)
        if index == nil || index == -1 {
            return
        }

        let displayCourse = courseList[index!]
        courseNameField.stringValue = displayCourse.courseName
        courseRoomField.stringValue = displayCourse.courseRoom
        courseIdentifierField.stringValue = displayCourse.courseCode
        courseScoreField.stringValue = String(format: "%.1f", arguments: [displayCourse.courseScore])
        courseTimeField.stringValue = displayCourse.getTime()
    }

    func didWriteEvent(title: String) {
        DispatchQueue.main.async {
            self.inputCounter += 1
            self.loadingTextField.stringValue = "正在创建「\(title)」。不要现在退出。"
            if self.inputCounter == self.expectedCounter {
                self.loadingTextField.stringValue = "已经成功写入 \(self.inputCounter) / \(self.expectedCounter) 个日历事件。"
                self.resumeUI()
            }
        }
    }

    func showErrorMessage(errorMsg: String) {
        let errorAlert: NSAlert = NSAlert()
        errorAlert.informativeText = errorMsg
        errorAlert.messageText = "出错啦"
        errorAlert.addButton(withTitle: "嗯")
        errorAlert.addButton(withTitle: "打开系统偏好设置")
        errorAlert.alertStyle = NSAlert.Style.informational
        errorAlert.beginSheetModal(for: view.window!) { returnCode in
            if returnCode == NSApplication.ModalResponse.alertSecondButtonReturn {
                openRequestPanel()
            }
        }
    }
    
    func showErrorMessageNormal(errorMsg: String) {
        let errorAlert: NSAlert = NSAlert()
        errorAlert.informativeText = errorMsg
        errorAlert.messageText = "出错啦"
        errorAlert.addButton(withTitle: "嗯")
        errorAlert.alertStyle = NSAlert.Style.informational
        errorAlert.beginSheetModal(for: view.window!)
    }

    func showError(error: String) {
        DispatchQueue.main.async {
            self.showErrorMessage(errorMsg: error)
            self.resumeUI()
        }
    }
}

protocol writeCalendarDelegate: NSObjectProtocol {
    func didWriteEvent(title: String) -> Void
    func startWriteCalendar() -> Void
    func showError(error: String) -> Void
}

protocol readInHTMLDelegate: NSObjectProtocol {
    var htmlDoc: String { get set }
}
