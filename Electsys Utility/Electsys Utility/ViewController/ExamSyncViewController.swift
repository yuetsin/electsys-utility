//
//  ExamSyncViewController.swift
//  Electsys Utility
//
//  Created by yuxiqian on 2018/9/6.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Cocoa
import Kanna


class ExamSyncViewController: NSViewController, examQueryDelegate, writeCalendarDelegate {

    
    var exams: [Exam] = []
    var helper: CalendarHelper?
    var shouldRemind: Bool = true
    var accountDelegate: loginHelperDelegate?
    var UIDelegate: UIManagerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        yearSelector.removeAllItems()
        for year in 0...8 {
            yearSelector.addItem(withTitle: ConvertToString(Year(rawValue: 2018 - year)!))
        }
    }
    
    func parseResponse(examData: String) {
        resumeUI()
        exams = []
        let studentID: String = getByXpath(examData, "//*[@id=\"lblXh\"]")
        let studentName: String = getByXpath(examData, "//*[@id=\"lblXm\"]")
        let studentMajor: String = getByXpath(examData, "//*[@id=\"lblZy\"]")
        
        if studentID != "0" || studentName != "0" || studentMajor != "0" {
            showInfoMessage(infoMsg: "请确认个人信息：\n\(studentMajor)专业\(studentName)，学号 \(studentID)。")
//        print(examData)
        } else {
            self.UIDelegate?.switchToPage(index: 3)
            self.accountDelegate?.forceResetAccount()
            self.UIDelegate?.lockIcon()
            return
        }
        if let html = try? HTML(html: examData, encoding: .utf8) {
            testInfo.removeAllItems()
            for item in html.xpath("//*[@id=\"gridMain\"]/tr[position()>1]") {
//                print(sanitize(item.text ?? "0"))
                let exam = Exam()
                let innerHtml = item.toHTML!
                exam.name = getByXpath(innerHtml, "//td[1]")
                exam.location = getByXpath(innerHtml, "//td[4]")
                exam.teacher = getByXpath(innerHtml, "//td[5]")
                let time = getByXpath(innerHtml, "//td[3]")
                let date = time.prefix(10)
                var numbersArray = time.components(separatedBy: CharacterSet(charactersIn: ":：－"))
                // ：和:两种冒号混用……绝了
                // － 不是 - ...
                numbersArray[0] = String(numbersArray[0].suffix(2))
                // 拆出两位数字作为时间

                let timeAndDateFormatter = DateFormatter()
                timeAndDateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                if numbersArray.count < 4 {
                    continue
                }
                
                let offset = numbersArray.count - 4
                let startDateString = date + " \(numbersArray[offset]):\(numbersArray[offset + 1])"
                let endDateString = date + " \(numbersArray[offset + 2]):\(numbersArray[offset + 3])"
                exam.startDate = timeAndDateFormatter.date(from: String(startDateString))
                exam.endDate = timeAndDateFormatter.date(from: String(endDateString))
                exams.append(exam)
                testInfo.addItem(withTitle: exam.generatePrompt())
            }
        }
    }
    
    
    @IBOutlet weak var yearSelector: NSPopUpButton!
    @IBOutlet weak var termSelector: NSPopUpButton!
    @IBOutlet weak var loadButton: NSButton!
    @IBOutlet weak var testInfo: NSPopUpButton!
    @IBOutlet weak var syncTo: NSPopUpButton!
    @IBOutlet weak var calendarName: NSTextField!
    @IBOutlet weak var getRandomName: NSButton!
    @IBOutlet weak var remindMe: NSButton!
    @IBOutlet weak var startSync: NSButton!
    
    
    @IBAction func generateName(_ sender: NSButton) {
        self.calendarName.stringValue = getRandomNames()
    }
    
    @IBAction func startRequest(_ sender: NSButton) {
        disableUI()
        let examSyncer = ExamSync()
        examSyncer.delegate = self
        var term: Term?
        if termSelector.selectedItem!.title == "秋季学期" {
            term = .Autumn
        } else {
            term = .Spring
        }
        examSyncer.getExamData(year: ConvertToYear((yearSelector.selectedItem?.title)!), term: term!)
    }
    
    @IBAction func startSync(_ sender: NSButton) {
        if self.calendarName.stringValue == "" {
            self.calendarName.stringValue = "jAccount 同步"
        }
        if syncTo.selectedItem!.title == "Mac 上的本地日历" {
            helper = CalendarHelper(name: self.calendarName.stringValue , type: .local, delegate: self)
        } else {
            helper = CalendarHelper(name: self.calendarName.stringValue , type: .calDAV, delegate: self)
        }
        shouldRemind = (self.remindMe.state == .on)
        helper?.delegate = self
        disableUI()
    }
    
    func didWriteEvent(title: String) {
//        promptTextField.stringValue = "正在写入：\(title)。此时请不要退出。"
    }
    
    func startWriteCalendar() {
        DispatchQueue.global().async {
            for exam in self.exams {
                self.helper?.addToDate(exam: exam, remind: self.shouldRemind)
            }
            DispatchQueue.main.async {
                self.resumeUI()
                self.showInfoMessage(infoMsg: "已完成同步。")
            }
        }
    }
    
    func showError(error: String) {
        DispatchQueue.main.async {
            let errorAlert: NSAlert = NSAlert()
            errorAlert.informativeText = error
            errorAlert.messageText = "出错啦"
            errorAlert.addButton(withTitle: "嗯")
            errorAlert.addButton(withTitle: "打开系统偏好设置")
            errorAlert.alertStyle = NSAlert.Style.informational
            errorAlert.beginSheetModal(for: self.view.window!) { (returnCode) in
                if returnCode == NSApplication.ModalResponse.alertSecondButtonReturn {
                    openRequestPanel()
                }
            }
            self.resumeUI()
        }
    }
    

    
    func disableUI() {
        yearSelector.isEnabled = false
        termSelector.isEnabled = false
        loadButton.isEnabled = false
        testInfo.isEnabled = false
        syncTo.isEnabled = false
        calendarName.isEnabled = false
        getRandomName.isEnabled = false
        remindMe.isEnabled = false
        startSync.isEnabled = false
    }
    
    func resumeUI() {
        yearSelector.isEnabled = true
        termSelector.isEnabled = true
        loadButton.isEnabled = true
        testInfo.isEnabled = true
        syncTo.isEnabled = true
        calendarName.isEnabled = true
        getRandomName.isEnabled = true
        remindMe.isEnabled = true
        startSync.isEnabled = true
    }
    
    func showInfoMessage(infoMsg: String) {
        let errorAlert: NSAlert = NSAlert()
        errorAlert.informativeText = infoMsg
        errorAlert.messageText = "提示"
        errorAlert.addButton(withTitle: "嗯")
        errorAlert.alertStyle = NSAlert.Style.informational
        errorAlert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
}
