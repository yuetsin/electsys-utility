//
//  ScoreQueryViewController.swift
//  Electsys Utility
//
//  Created by 法好 on 2019/9/15.
//  Copyright © 2019 yuxiqian. All rights reserved.
//

import Cocoa

class ScoreQueryViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, YearAndTermSelectionDelegate {
    
    var scoreList: [NGScore] = []
    var openedWindow: NSWindow?

    @IBOutlet var tableView: NSTableView!
    @IBOutlet weak var promptTextField: NSTextField!
    @IBOutlet weak var blurredView: RMBlurredView!
    
    @IBAction func restartAnalyse(_ sender: NSButton) {
        scoreList.removeAll()
        tableView.reloadData()
        updateTableViewContents()
        openYearTermSelectionPanel()
    }
    
    override func viewDidLoad() {
        updateTableViewContents()
        super.viewDidLoad()
    }

    override func viewDidAppear() {
        if scoreList.count == 0 {
            openYearTermSelectionPanel()
        }
        updateTableViewContents()
        super.viewDidAppear()
    }
    
    func successCourseDataTransfer(data: [NGCourse]) {
        NSLog("bad request type")
    }
    
    func successExamDataTransfer(data: [Exam]) {
        NSLog("bad request type")
    }
    
    func successScoreDataTransfer(data: [NGScore]) {
        scoreList = data
        updateTableViewContents()
    }
    
    func shutWindow() {
        if openedWindow != nil {
            view.window?.endSheet(openedWindow!)
            openedWindow = nil
        }
    }
    
    func updateTableViewContents() {
        if scoreList.count == 0 {
            promptTextField.stringValue = "目前没有科目的考试成绩。"
            view.window?.makeFirstResponder(blurredView)
            blurredView.blurRadius = 3.0
            blurredView.isHidden = false
            return
        }
        
        blurredView.isHidden = true
        blurredView.blurRadius = 0.0

        promptTextField.isEnabled = true
        promptTextField.stringValue = "现有 \(scoreList.count) 门科目的考试成绩。"
        tableView.reloadData()
    }
    
    func openYearTermSelectionPanel() {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Year and Term Selection Window")) as! NSWindowController

        if let window = windowController.window {
            (window.contentViewController as! TermSelectingViewController).successDelegate = self
            (window.contentViewController as! TermSelectingViewController).requestType = .score
            view.window?.beginSheet(window, completionHandler: nil)
            openedWindow = window
        }
    }

    fileprivate enum CellIdentifiers {
        static let NameCell = "CourseNameCellID"
        static let CodeCell = "CourseCodeCellID"
        static let TeacherCell = "TeacherNameCellID"
        static let ScoreCell = "FinalScoreCellID"
        static let PointCell = "PointCellID"
    }

    // MARK: - NSTableViewDelegate and NSTableViewDataSource

    func numberOfRows(in tableView: NSTableView) -> Int {
        return scoreList.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if row >= scoreList.count {
            return nil
        }
        
        var text: String = ""
        var cellIdentifier: String = ""
        
        let item = scoreList[row]
        
        if tableColumn == tableView.tableColumns[0] {
            text = item.courseName ?? "课程名称"
            cellIdentifier = CellIdentifiers.NameCell
        } else if tableColumn == tableView.tableColumns[1] {
            text = item.courseCode ?? "课号"
            cellIdentifier = CellIdentifiers.CodeCell
        } else if tableColumn == tableView.tableColumns[2] {
            text = item.teacher ?? "教师"
            cellIdentifier = CellIdentifiers.TeacherCell
        } else if tableColumn == tableView.tableColumns[3] {
            text = "\(item.finalScore ?? 0)"
            cellIdentifier = CellIdentifiers.ScoreCell
        } else if tableColumn == tableView.tableColumns[4] {
            text = String.init(format: "%.2f", item.scorePoint ?? "0.0")
            cellIdentifier = CellIdentifiers.PointCell
        }

        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
}
