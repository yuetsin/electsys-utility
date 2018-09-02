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
        //        outlineView.reloadData()
    }
    
    var htmlDoc: String = ""
//    var courseList: [Course] = []
    var displayWeek: [Day] = []
    var startDate: Date?

    
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
    
    @IBOutlet weak var courseNameField: NSTextField!
    @IBOutlet weak var courseRoomField: NSTextField!
    @IBOutlet weak var courseIdentifierField: NSTextField!
    @IBOutlet weak var courseScoreField: NSTextField!
    @IBOutlet weak var courseTimeField: NSTextField!

    
    func disableUI() {
        self.coursePopUpList.isEnabled = false
        self.willLoadSummerBox.isEnabled = false
        self.willRemindBox.isEnabled = false
        self.remindTypeSelector.isEnabled = false
        self.startWeekSelector.isEnabled = false
        self.syncAccountType.isEnabled = false
        self.courseNameField.isEnabled = false
        self.courseRoomField.isEnabled = false
        self.courseIdentifierField.isEnabled = false
        self.courseScoreField.isEnabled = false
        self.courseTimeField.isEnabled = false
        self.calendarTextField.isEnabled = false
        self.relsamaHouwyButton.isEnabled = false
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
        self.courseIdentifierField.isEnabled = true
        self.courseScoreField.isEnabled = true
        self.courseTimeField.isEnabled = true
        self.calendarTextField.isEnabled = true
        self.relsamaHouwyButton.isEnabled = true
        self.loadingRing.isHidden = true
        remindTapped(self.willRemindBox)
        updatePopUpSelector()
    }
    
    @IBAction func remindTapped(_ sender: NSButton) {
        if willRemindBox.state == NSControl.StateValue.on {
            remindTypeSelector.isEnabled = true
        } else {
            remindTypeSelector.isEnabled = false
        }
    }
    
    @IBAction func restartAnalyse(_ sender: NSButton) {
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

        let calendarHelper = CalendarHelper()
        calendarHelper.delegate = self
        var inCalendar: EKCalendar
        print("新课表的名字应该叫：\(self.calendarTextField.stringValue)")
        switch syncAccountType.selectedItem!.title {
        case "CalDAV 或 iCloud 日历":
            inCalendar = calendarHelper.initializeCalendar(name: self.calendarTextField.stringValue,
                                                           type: .calDAV)!
            break
        case "Mac 上的本地日历":
            inCalendar = calendarHelper.initializeCalendar(name: self.calendarTextField.stringValue,
                                                           type: .local)!
            break
        default:
            return
        }
        
        var remindType: remindType?
        if willRemindBox.state == .on {
            switch self.remindTypeSelector.selectedItem!.title {
            case "上课前 15 分钟":
                remindType = .fifteenMinutes
                break
            case "上课前 10 分钟":
                remindType = .tenMinutes
                break
            case "上课时":
                remindType = .atCourseStarts
                break
            default:
                remindType = .noReminder
            }
        }
        disableUI()
        DispatchQueue.global().async {
            for day in self.displayWeek {
                for course in day.children {
                    for week in generateArray(start: course.weekStartsAt,
                                              end: course.weekEndsAt,
                                              shift: course.shiftWeek) {
                                                calendarHelper.addToCalendar(date: (self.startDate!.convertWeekToDate(week: week, weekday: course.courseDay)),
                                                              title: course.courseName,
                                                              place: course.courseRoom,
                                                              start: defaultLessonTime[course.dayStartsAt],
                                                              end: defaultLessonTime[course.dayStartsAt + course.courseDuration - 1].getTime(passed: durationMinutesOfLesson),
                                                              remindType: remindType!, in: inCalendar)
                    }
                }
            }
            DispatchQueue.main.async {
                self.resumeUI()
            }
        }
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
//        print(":Did write \(title) into the calendar.")
    }
}

protocol writeCalendarDelegate: NSObjectProtocol {
    func didWriteEvent(title: String) -> ()
}
