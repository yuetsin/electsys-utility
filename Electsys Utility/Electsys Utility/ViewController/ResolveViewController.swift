//
//  ResolveViewController.swift
//  Sync Utility
//
//  Created by yuxiqian on 2018/8/31.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Cocoa
import EventKit

class ResolveViewController: NSViewController, writeCalendarDelegate, YearAndTermSelectionDelegate {

    func successCourseDataTransfer(data: [NGCourse]) {
        courseList = data
        updatePopUpSelector()
    }

    func successExamDataTransfer(data: [Exam]) {
        NSLog("bad request type")
    }

    func successScoreDataTransfer(data: [String]) {
        NSLog("bad request type")
    }
    
    func shutWindow() {
        if openedWindow != nil {
            view.window?.endSheet(openedWindow!)
            openedWindow = nil
        }
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
    }
    
    var openedWindow: NSWindow?

    func openYearTermSelectionPanel() {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Year and Term Selection Window")) as! NSWindowController

        if let window = windowController.window {
            (window.contentViewController as! TermSelectingViewController).successDelegate = self
            (window.contentViewController as! TermSelectingViewController).requestType = .course
            view.window?.beginSheet(window, completionHandler: nil)
            openedWindow = window
        }
    }

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
        var displayCourse = courseList[index!]
        displayCourse.courseName = courseNameField.stringValue
        displayCourse.courseRoom = courseRoomField.stringValue
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
            showError(error: "没有任何待同步的课表。")
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
            blurredView.isHidden = false
            promptTextField.isEnabled = false
            courseNameField.stringValue = ""
            courseRoomField.stringValue = ""
            courseIdentifierField.stringValue = ""
            courseScoreField.stringValue = ""
            courseTimeField.stringValue = ""
            return
        }
        
        blurredView.isHidden = true

        promptTextField.isEnabled = true
        promptTextField.stringValue = "现有 \(courseList.count) 条课程信息。"

        for course in courseList {
            coursePopUpList.addItem(withTitle: course.getExtraIdentifier())
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
                                                       title: course.courseName,
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
