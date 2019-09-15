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
    @IBOutlet var promptTextField: NSTextField!
    @IBOutlet var blurredView: RMBlurredView!

    @IBAction func restartAnalyse(_ sender: NSButton) {
        scoreList.removeAll()
        tableView.reloadData()
        updateTableViewContents()
        openYearTermSelectionPanel()
    }

    @IBAction func calculateGpa(_ sender: NSButton) {
        if scoreList.count == 0 {
            return
        }
        let gpaResult = GPAKits.calculateGpa(scores: scoreList)
        if gpaResult == nil {
            showErrorMessageNormal(errorMsg: "未能成功计算您的平均绩点（GPA）。")
        } else {
            showGpaMessage(infoMsg: "根据「\(GPAKits.GpaStrategies[PreferenceKits.gpaStrategy.rawValue])」计算，\n您的平均绩点（GPA）为 \(String(format: "%.2f", gpaResult!))。")
        }
    }

    override func viewDidLoad() {
        updateTableViewContents()

        let sortByName = NSSortDescriptor(key: "sortByName", ascending: true)
        let sortByCode = NSSortDescriptor(key: "sortByCode", ascending: true)
        let sortByTeacher = NSSortDescriptor(key: "sortByTeacher", ascending: true)
        let sortByScore = NSSortDescriptor(key: "sortByScore", ascending: true)
        let sortByPoint = NSSortDescriptor(key: "sortByPoint", ascending: true)

        tableView.tableColumns[0].sortDescriptorPrototype = sortByName
        tableView.tableColumns[1].sortDescriptorPrototype = sortByCode
        tableView.tableColumns[2].sortDescriptorPrototype = sortByTeacher
        tableView.tableColumns[3].sortDescriptorPrototype = sortByScore
        tableView.tableColumns[4].sortDescriptorPrototype = sortByPoint

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
            promptTextField.stringValue = "目前没有任何科目的考试成绩。"
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

    func showErrorMessageNormal(errorMsg: String) {
        let errorAlert: NSAlert = NSAlert()
        errorAlert.informativeText = errorMsg
        errorAlert.messageText = "出错啦"
        errorAlert.addButton(withTitle: "嗯")
        errorAlert.alertStyle = NSAlert.Style.informational
        errorAlert.beginSheetModal(for: view.window!)
    }

    func showGpaMessage(infoMsg: String) {
        let gpaAlert: NSAlert = NSAlert()
        gpaAlert.informativeText = infoMsg
        gpaAlert.messageText = "平均绩点计算结果"
        gpaAlert.addButton(withTitle: "嗯")
        gpaAlert.addButton(withTitle: "了解更多…")
        gpaAlert.alertStyle = NSAlert.Style.informational
        gpaAlert.beginSheetModal(for: view.window!) { returnCode in
            if returnCode == NSApplication.ModalResponse.alertSecondButtonReturn {
                if let url = URL(string: "https://apps.chasedream.com/gpa/#"), NSWorkspace.shared.open(url) {
                    // successfully opened
                }
            }
        }
    }

    fileprivate enum CellIdentifiers {
        static let NameCell = "CourseNameCellID"
        static let CodeCell = "CourseCodeCellID"
        static let TeacherCell = "TeacherNameCellID"
        static let ScoreCell = "FinalScoreCellID"
        static let PointCell = "PointCellID"
    }
    
//
//    let sortByName = NSSortDescriptor(key: "sortByName", ascending: true)
//    let sortByCode = NSSortDescriptor(key: "sortByCode", ascending: true)
//    let sortByTeacher = NSSortDescriptor(key: "sortByTeacher", ascending: true)
//    let sortByScore = NSSortDescriptor(key: "sortByScore", ascending: true)
//    let sortByPoint = NSSortDescriptor(key: "sortByPoint", ascending: true)

    func sortArray(_ sortKey: String, _ isAscend: Bool) {
        if scoreList.count <= 1 {
            return
        }
        switch sortKey {
        case "sortByName":
            func titleSorter(p1: NGScore?, p2: NGScore?) -> Bool {
                if p1?.courseName == nil {
                    return p2?.courseName == nil
                }
                if p2?.courseName == nil {
                    return p1?.courseName != nil
                }
                return (p1?.courseName!.compare(p2!.courseName!) == ComparisonResult.orderedAscending) == isAscend
            }
            scoreList.sort(by: titleSorter)
            tableView.reloadData()
            break
        case "sortByCode":
            func codeSorter(p1: NGScore?, p2: NGScore?) -> Bool {
                if p1?.courseCode == nil {
                    return p2?.courseCode == nil
                }
                if p2?.courseCode == nil {
                    return p1?.courseCode != nil
                }
                return (p1?.courseCode!.compare(p2!.courseCode!) == ComparisonResult.orderedDescending) == isAscend
            }
            scoreList.sort(by: codeSorter)
            tableView.reloadData()
            break
        case "sortByTeacher":
            func teacherSorter(p1: NGScore?, p2: NGScore?) -> Bool {
                if p1?.teacher == nil {
                    return p2?.teacher == nil
                }
                if p2?.teacher == nil {
                    return p1?.teacher != nil
                }
                return (p1?.teacher!.compare(p2!.teacher!) == ComparisonResult.orderedAscending) == isAscend
            }
            scoreList.sort(by: teacherSorter)
            tableView.reloadData()
            break
        case "sortByScore":
            func scoreSorter(p1: NGScore?, p2: NGScore?) -> Bool {
                if p1?.finalScore == nil {
                    return p2?.finalScore == nil
                }
                if p2?.finalScore == nil {
                    return p1?.finalScore != nil
                }
                return ((p1?.finalScore ?? 0) > (p2?.finalScore ?? 0)) == isAscend
            }
            scoreList.sort(by: scoreSorter)
            tableView.reloadData()
            break
            case "sortByPoint":
            func pointSorter(p1: NGScore?, p2: NGScore?) -> Bool {
                if p1?.scorePoint == nil {
                    return p2?.scorePoint == nil
                }
                if p2?.scorePoint == nil {
                    return p1?.scorePoint != nil
                }
                return (p1?.scorePoint ?? 0.0 > p2?.scorePoint ?? 0.0) == isAscend
            }
            scoreList.sort(by: pointSorter)
            tableView.reloadData()
            break
        case "badSortArgument":
            showErrorMessageNormal(errorMsg: "排序参数出错。")
            break
        default:
            break
        }
    }

    // MARK: - NSTableViewDelegate and NSTableViewDataSource

    func numberOfRows(in tableView: NSTableView) -> Int {
        return scoreList.count
    }

    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        guard let sortDescriptor = tableView.sortDescriptors.first else {
            return
        }
        //        NSLog(sortDescriptor.key ?? "badSortArgument")
        //        NSLog("now ascending == \(sortDescriptor.ascending)")
        sortArray(sortDescriptor.key ?? "badSortArgument", !sortDescriptor.ascending)
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if row >= scoreList.count {
            return nil
        }

        var text: String = ""
        var cellIdentifier: String = ""

        let item = scoreList[row]

        if tableColumn == tableView.tableColumns[0] {
            text = "\(item.courseName ?? "课程名称")（\(String(format: "%.1f", item.credit ?? 0.0)) 学分）"
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
            text = String(format: "%.1f", item.scorePoint ?? "0.0")
            cellIdentifier = CellIdentifiers.PointCell
        }

        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
}
