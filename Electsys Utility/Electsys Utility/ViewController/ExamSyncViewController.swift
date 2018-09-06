//
//  ExamSyncViewController.swift
//  Electsys Utility
//
//  Created by yuxiqian on 2018/9/6.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Cocoa


class ExamSyncViewController: NSViewController, examQueryDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        yearSelector.removeAllItems()
        for year in 0...7 {
            yearSelector.addItem(withTitle: ConvertToString(Year(rawValue: 2017 - year)!))
        }
        self.promptTextField.stringValue = ""
    }
    
    func parseResponse(examData: String) {
        print(examData)
    }
    
    
    @IBOutlet weak var yearSelector: NSPopUpButton!
    @IBOutlet weak var termSelector: NSPopUpButton!
    @IBOutlet weak var loadButton: NSButton!
    @IBOutlet weak var promptTextField: NSTextField!
    @IBOutlet weak var testInfo: NSPopUpButton!
    @IBOutlet weak var syncTo: NSPopUpButton!
    @IBOutlet weak var calendarName: NSTextField!
    @IBOutlet weak var getRandomName: NSButton!
    @IBOutlet weak var remindMe: NSButton!
    @IBOutlet weak var startSync: NSButton!
    
    
    @IBAction func generateName(_ sender: NSButton) {
        self.calendarName.stringValue = getRandomNames()
    }
    
    @IBAction func syncButtonClicked(_ sender: NSButton) {
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
}
