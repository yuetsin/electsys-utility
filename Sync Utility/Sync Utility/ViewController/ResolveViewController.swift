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
    
    @IBAction func remindTapped(_ sender: NSButton) {
        if willRemindBox.state == NSControl.StateValue.on {
            remindTypeSelector.isEnabled = true
        } else {
            remindTypeSelector.isEnabled = false
        }
    }
    
    func initializeInfo() {
        for dayNum in 1...7 {
            displayWeek.append(Day(dayNum))
        }
        parseCourseSheet(htmlDoc,
//                         &courseList,
                         &displayWeek,
                         true)
        self.promptTextField.stringValue = "已经成功导入 \(getAllCount(week: displayWeek)) 条课程信息。"
        for dayNum in 1...7 {
            for course in displayWeek[dayNum - 1].children {
                self.coursePopUpList.addItem(withTitle: course.getExtraIdentifier())
            }
        }
    }
}
