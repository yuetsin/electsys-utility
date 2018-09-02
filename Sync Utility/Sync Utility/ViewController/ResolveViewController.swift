//
//  ResolveViewController.swift
//  Sync Utility
//
//  Created by yuxiqian on 2018/8/31.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Cocoa

class ResolveViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        //        print(self.htmlDoc)
        initializeInfo()
        self.startWeekSelector.dateValue = Date()
        onDatePicked(startWeekSelector)
        //        outlineView.reloadData()
    }
    
    var htmlDoc: String = ""
//    var courseList: [Course] = []
    var displayWeek: [Day] = []
    
    @IBOutlet weak var coursePopUpList: NSPopUpButton!
    @IBOutlet weak var promptTextField: NSTextField!
    @IBOutlet weak var willLoadSummerBox: NSButton!
    @IBOutlet weak var willRemindBox: NSButton!
    @IBOutlet weak var remindTypeSelector: NSPopUpButton!
    @IBOutlet weak var startWeekSelector: NSDatePicker!
    @IBOutlet weak var startWeekIndicator: NSTextField!
    
    @IBOutlet weak var courseNameField: NSTextField!
    @IBOutlet weak var courseRoomField: NSTextField!
    @IBOutlet weak var courseIdentifierField: NSTextField!
    @IBOutlet weak var courseScoreField: NSTextField!
    @IBOutlet weak var courseTimeField: NSTextField!
    
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
    }
}
