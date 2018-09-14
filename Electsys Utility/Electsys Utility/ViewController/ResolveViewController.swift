//
//  ResolveViewController.swift
//  Sync Utility
//
//  Created by yuxiqian on 2018/8/31.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Cocoa
import EventKit

class ResolveViewController: NSViewController, writeCalendarDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        //        print(self.htmlDoc)
        initializeInfo()
        self.startWeekSelector.dateValue = Date()
        onDatePicked(startWeekSelector)
        self.loadingRing.startAnimation(self)
        self.loadingTextField.stringValue = ""
        self.courseIdentifierField.isEnabled = false
        self.courseScoreField.isEnabled = false
        self.courseTimeField.isEnabled = false
    }
    
    var htmlDoc: String = ""
//    var courseList: [Course] = []
    var displayWeek: [Day] = []
    var startDate: Date?
    var inputCounter: Int = 0
    var expectedCounter: Int = 0
    var calendarHelper: CalendarHelper?
    var remindState: remindType = .fifteenMinutes
    
    @IBOutlet weak var coursePopUpList: NSPopUpButton!
    @IBOutlet weak var promptTextField: NSTextField!
    @IBOutlet weak var willLoadSummerBox: NSButton!
    @IBOutlet weak var willRemindBox: NSButton!
    @IBOutlet weak var remindTypeSelector: NSPopUpButton!
    @IBOutlet weak var startWeekSelector: NSDatePicker!
    @IBOutlet weak var startWeekIndicator: NSTextField!
    @IBOutlet weak var syncAccountType: NSPopUpButton!
    @IBOutlet weak var calendarTextField: NSTextField!
    @IBOutlet weak var loadingRing: NSProgressIndicator!
    @IBOutlet weak var relsamaHouwyButton: NSButton!
    @IBOutlet weak var startSyncButton: NSButton!
    
    @IBOutlet weak var courseNameField: NSTextField!
    @IBOutlet weak var courseRoomField: NSTextField!
    @IBOutlet weak var courseIdentifierField: NSTextField!
    @IBOutlet weak var courseScoreField: NSTextField!
    @IBOutlet weak var courseTimeField: NSTextField!
    @IBOutlet weak var loadingTextField: NSTextField!
    @IBOutlet weak var diceButton: NSButton!
    
   
    
    func disableUI() {
        self.coursePopUpList.isEnabled = false
        self.willLoadSummerBox.isEnabled = false
        self.willRemindBox.isEnabled = false
        self.remindTypeSelector.isEnabled = false
        self.startWeekSelector.isEnabled = false
        self.syncAccountType.isEnabled = false
        self.courseNameField.isEnabled = false
        self.courseRoomField.isEnabled = false
        self.calendarTextField.isEnabled = false
        self.relsamaHouwyButton.isEnabled = false
        self.startSyncButton.isEnabled = false
        self.diceButton.isEnabled = false
        self.loadingRing.isHidden = false
    }
    
    func resumeUI() {
        self.coursePopUpList.isEnabled = true
        self.willLoadSummerBox.isEnabled = true
        self.willRemindBox.isEnabled = true
        self.remindTypeSelector.isEnabled = true
        self.startWeekSelector.isEnabled = true
        self.syncAccountType.isEnabled = true
        self.courseNameField.isEnabled = true
        self.courseRoomField.isEnabled = true
        self.calendarTextField.isEnabled = true
        self.relsamaHouwyButton.isEnabled = true
        self.startSyncButton.isEnabled = true
        self.diceButton.isEnabled = true
        self.loadingRing.isHidden = true
        remindTapped(self.willRemindBox)
        updatePopUpSelector()
    }
    
    @IBAction func remindTapped(_ sender: NSButton) {
        if willRemindBox.state == NSControl.StateValue.on {
            remindTypeSelector.isEnabled = true
            switch self.remindTypeSelector.selectedItem!.title {
            case "上课前 15 分钟":
                self.remindState = .fifteenMinutes
                break
            case "上课前 10 分钟":
                self.remindState = .tenMinutes
                break
            case "上课时":
                self.remindState = .atCourseStarts
                break
            default:
                self.remindState = .noReminder
            }
        } else {
            remindTypeSelector.isEnabled = false
            self.remindState = .noReminder
        }
    }
    
    @IBAction func updateRemindState(_ sender: NSPopUpButton) {
        remindTapped(willRemindBox)
    }
    
    
    @IBAction func restartAnalyse(_ sender: NSButton) {
        self.loadingTextField.stringValue = ""
        initializeInfo()
    }
    
    func initializeInfo() {
        displayWeek.removeAll()
        for dayNum in 1...7 {
            displayWeek.append(Day(dayNum))
        }
        parseCourseSheet(htmlDoc,
//                         &courseList,
                         &displayWeek,
                         self.willLoadSummerBox.state == .on)
        updatePopUpSelector()
    }
    
    @IBAction func makeRandomName(_ sender: NSButton) {
        self.calendarTextField.stringValue = getRandomNames()
    }
    
    @IBAction func popUpClicked(_ sender: NSPopUpButton) {
        updateInfoField()
    }
    
    @IBAction func checkSummerBox(_ sender: NSButton) {
        onDatePicked(startWeekSelector)
        initializeInfo()
    }
    
    @IBAction func removePiece(_ sender: NSButton) {
        if self.coursePopUpList.itemArray.count == 0 {
            return
        }
        let index = self.coursePopUpList.selectedItem?.indexIn(((self.coursePopUpList?.itemArray)!))
        if index == -1 {
            return
        }
        let removeCourse = findCourseByIndex(index! + 1, &displayWeek)
        for day in self.displayWeek {
            for item in day.children {
                if removeCourse == item {
                    if let index = day.children.index(of: item) {
                        day.children.remove(at: index)
                    }
                }
            }
        }
        updatePopUpSelector()
    }
    
    @IBAction func saveInfo(_ sender: NSButton) {
        if self.coursePopUpList.itemArray.count == 0 {
            return
        }
        let index = self.coursePopUpList.selectedItem?.indexIn(((self.coursePopUpList?.itemArray)!))
        if index == -1 {
            return
        }
        let displayCourse = findCourseByIndex(index! + 1, &displayWeek)
        displayCourse.courseName = self.courseNameField.stringValue
        displayCourse.courseRoom = self.courseRoomField.stringValue
        updatePopUpSelector(at: index!)
    }
    
    @IBAction func onDatePicked(_ sender: NSDatePicker) {
        var startDate = sender.dateValue
        while startDate.getWeekDay() > 1 {
            startDate = startDate.addingTimeInterval(-secondsInDay)
//            print("Date: \(startDate.getStringExpression()), weekday: \(startDate.getWeekDay())")
        }
        self.startWeekIndicator.stringValue =
        "以 \(startDate.getStringExpression())，星期一作为主学期第一周的开始。"
        if willLoadSummerBox.state == .on {
            self.startWeekIndicator.stringValue +=
            "\n同时以 \(startDate.addingTimeInterval(secondsInEighteenWeeks).getStringExpression())，星期一作为暑期小学期的开始。"
        }
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
        inputCounter = 0
        expectedCounter = 0
        print("课表的名字：\(self.calendarTextField.stringValue)")
        switch syncAccountType.selectedItem!.title {
        case "CalDAV 或 iCloud 日历":
            calendarHelper = CalendarHelper(name: self.calendarTextField.stringValue,
                                            type: .calDAV, delegate: self)
            break
        case "Mac 上的本地日历":
            calendarHelper = CalendarHelper(name: self.calendarTextField.stringValue,
                                            type: .local, delegate: self)
            break
        default:
            return
        }
        

        disableUI()

//        calendarHelper.commitChanges()
    }
    
    func updatePopUpSelector(at itemIndex: Int = 0) {
        self.coursePopUpList.removeAllItems()
        let courseCount = getAllCount(week: displayWeek)
        if courseCount == 0 {
            self.promptTextField.stringValue = "目前没有任何课程信息。"
            self.promptTextField.isEnabled = false
            self.courseNameField.stringValue = ""
            self.courseRoomField.stringValue = ""
            self.courseIdentifierField.stringValue = ""
            self.courseScoreField.stringValue = ""
            self.courseTimeField.stringValue = ""
            return
        }
        
        self.promptTextField.isEnabled = true
        self.promptTextField.stringValue = "现有 \(getAllCount(week: displayWeek)) 条课程信息。"
        for dayNum in 1...7 {
            for course in displayWeek[dayNum - 1].children {
                self.coursePopUpList.addItem(withTitle: course.getExtraIdentifier())
            }
        }
        if itemIndex != 0 {
            self.coursePopUpList.selectItem(at: itemIndex)
        }
        updateInfoField()
    }
    
    func startWriteCalendar() {
        DispatchQueue.global().async {
            for day in self.displayWeek {
                for course in day.children {
                    for week in generateArray(start: course.weekStartsAt,
                                              end: course.weekEndsAt,
                                              shift: course.shiftWeek) {
                                                self.expectedCounter += 1
                                                self.calendarHelper!.addToCalendar(date: (self.startDate!.convertWeekToDate(week: week, weekday: course.courseDay)),
                                                                              title: course.courseName,
                                                                              place: course.courseRoom,
                                                                              start: defaultLessonTime[course.dayStartsAt],
                                                                              end: defaultLessonTime[course.dayStartsAt + course.courseDuration - 1].getTime(passed: durationMinutesOfLesson),
                                                                              remindType: self.remindState)
                    }
                }
            }
        }
        
    }
    
    func updateInfoField() {
        let index = self.coursePopUpList.selectedItem?.indexIn(((self.coursePopUpList?.itemArray)!))
        var displayCourse = errorCourse
        if index != -1 {
            displayCourse = findCourseByIndex(index! + 1, &displayWeek)
        }
        self.courseNameField.stringValue = displayCourse.courseName
        self.courseRoomField.stringValue = displayCourse.courseRoom
        self.courseIdentifierField.stringValue = displayCourse.courseIdentifier
        self.courseScoreField.stringValue = String(format: "%.1f", arguments: [displayCourse.courseScore])
        self.courseTimeField.stringValue = displayCourse.getTime()
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
        errorAlert.beginSheetModal(for: self.view.window!) { (returnCode) in
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
    func didWriteEvent(title: String) -> ()
    func startWriteCalendar() -> ()
    func showError(error: String) -> ()
}
