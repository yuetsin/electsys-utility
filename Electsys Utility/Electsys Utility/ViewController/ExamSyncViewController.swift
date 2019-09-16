//
//  ExamSyncViewController.swift
//  Electsys Utility
//
//  Created by yuxiqian on 2018/9/6.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Cocoa
import Kanna


class ExamSyncViewController: NSViewController, writeCalendarDelegate {
    
    var exams: [NGExam] = []
    var helper: CalendarHelper?
    var shouldRemind: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewDidAppear() {
        showInfoMessage(infoMsg: "由于新版教学信息服务网尚在迁移中，同步考试安排功能暂不可用。")
    }
    
    
    @IBOutlet weak var testInfo: NSPopUpButton!
    @IBOutlet weak var syncTo: NSPopUpButton!
    @IBOutlet weak var calendarName: NSTextField!
    @IBOutlet weak var getRandomName: NSButton!
    @IBOutlet weak var remindMe: NSButton!
    @IBOutlet weak var startSync: NSButton!
    
    
    @IBAction func generateName(_ sender: NSButton) {
        self.calendarName.stringValue = getRandomNames()
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
            if self.view.window! == nil {
                self.resumeUI()
                return
            }
            errorAlert.beginSheetModal(for: self.view.window!) { (returnCode) in
                if returnCode == NSApplication.ModalResponse.alertSecondButtonReturn {
                    openRequestPanel()
                }
            }
            self.resumeUI()
        }
    }
    

    
    func disableUI() {
        testInfo.isEnabled = false
        syncTo.isEnabled = false
        calendarName.isEnabled = false
        getRandomName.isEnabled = false
        remindMe.isEnabled = false
        startSync.isEnabled = false
    }
    
    func resumeUI() {
        testInfo.isEnabled = true
        syncTo.isEnabled = true
        calendarName.isEnabled = true
        getRandomName.isEnabled = true
        remindMe.isEnabled = true
        startSync.isEnabled = true
    }
    
    func showInfoMessage(infoMsg: String) {
        if view.window == nil {
            return
        }
        let errorAlert: NSAlert = NSAlert()
        errorAlert.informativeText = infoMsg
        errorAlert.messageText = "提示"
        errorAlert.addButton(withTitle: "嗯")
        errorAlert.alertStyle = NSAlert.Style.informational
        errorAlert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
}
