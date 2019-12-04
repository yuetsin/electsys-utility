//
//  ExamSyncViewController.swift
//  Electsys Utility
//
//  Created by yuxiqian on 2018/9/6.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Cocoa
import Kanna


@available(OSX 10.12.2, *)
class ExamSyncViewController: NSViewController, writeCalendarDelegate, YearAndTermSelectionDelegate, NSTableViewDataSource, NSTableViewDelegate {
    
    func successCourseDataTransfer(data: [NGCourse]) {
        NSLog("bad type called")
        dismiss(sheetViewController)
    }
    
    func successExamDataTransfer(data: [NGExam]) {
        exams = data
        updateTableViewContents()
        dismiss(sheetViewController)
    }
    
    func successScoreDataTransfer(data: [NGScore]) {
        NSLog("bad type called")
        dismiss(sheetViewController)
    }
    
    func shutWindow() {
        dismiss(sheetViewController)
    }
    
    
    var exams: [NGExam] = []
    var helper: CalendarHelper?
    var shouldRemind: Bool = true
    
    @IBAction func TBSyncButtonTapped(_ sender: NSButton) {
        restartAnalyse(sender)
    }
    
    @IBOutlet weak var TBSyncButton: NSButton!
    lazy var sheetViewController: TermSelectingViewController = {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        return storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("YearAndTermViewController"))
            as! TermSelectingViewController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let sortByCourse = NSSortDescriptor(key: "sortByCourse", ascending: true)
//        let sortByName = NSSortDescriptor(key: "sortByName", ascending: true)
        let sortByTime = NSSortDescriptor(key: "sortByTime", ascending: true)
        let sortByRoom = NSSortDescriptor(key: "sortByRoom", ascending: true)
        let sortBySeat = NSSortDescriptor(key: "sortBySeat", ascending: true)

        tableView.tableColumns[0].sortDescriptorPrototype = sortByCourse
//        tableView.tableColumns[1].sortDescriptorPrototype = sortByName
        tableView.tableColumns[1].sortDescriptorPrototype = sortByTime
        tableView.tableColumns[2].sortDescriptorPrototype = sortByRoom
        tableView.tableColumns[3].sortDescriptorPrototype = sortBySeat

        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))

    }
    
    func sortArray(_ sortKey: String, _ isAscend: Bool) {
        if exams.count <= 1 {
            return
        }
        switch sortKey {
        case "sortByCourse":
            func titleSorter(p1: NGExam?, p2: NGExam?) -> Bool {
                if p1?.courseName == nil {
                    return p2?.courseName == nil
                }
                if p2?.courseName == nil {
                    return p1?.courseName != nil
                }
                return (p1?.courseName!.compare(p2!.courseName!) == ComparisonResult.orderedAscending) == isAscend
            }
            exams.sort(by: titleSorter)
            tableView.reloadData()
            break
        case "sortByName":
            func codeSorter(p1: NGExam?, p2: NGExam?) -> Bool {
                if p1?.name == nil {
                    return p2?.name == nil
                }
                if p2?.name == nil {
                    return p1?.name != nil
                }
                return (p1?.name!.compare(p2!.name!) == ComparisonResult.orderedDescending) == isAscend
            }
            exams.sort(by: codeSorter)
            tableView.reloadData()
            break
        case "sortByTime":
            func teacherSorter(p1: NGExam?, p2: NGExam?) -> Bool {
                if p1?.teacher == nil {
                    return p2?.teacher == nil
                }
                if p2?.teacher == nil {
                    return p1?.teacher != nil
                }
                return (p1?.teacher!.compare(p2!.teacher!) == ComparisonResult.orderedAscending) == isAscend
            }
            exams.sort(by: teacherSorter)
            tableView.reloadData()
            break
        case "sortByRoom":
            func scoreSorter(p1: NGExam?, p2: NGExam?) -> Bool {
                if p1?.location == nil {
                    return p2?.location == nil
                }
                if p2?.location == nil {
                    return p1?.location != nil
                }
                return (p1?.location!.compare(p2!.location!) == ComparisonResult.orderedAscending) == isAscend
            }
            exams.sort(by: scoreSorter)
            tableView.reloadData()
            break
        case "sortBySeat":
            func pointSorter(p1: NGExam?, p2: NGExam?) -> Bool {
                if p1?.seatNo == nil {
                    return p2?.seatNo == nil
                }
                if p2?.seatNo == nil {
                    return p1?.seatNo != nil
                }
                return (p1?.seatNo!.compare(p2!.seatNo!) == ComparisonResult.orderedAscending) == isAscend
            }
            exams.sort(by: pointSorter)
            tableView.reloadData()
            break
        case "badSortArgument":
            showErrorMessageNormal(errorMsg: "排序参数出错。")
            break
        default:
            break
        }
    }
    
    @objc func tableViewDoubleClick(_ sender: AnyObject) {
        if tableView.selectedRow < 0 || tableView.selectedRow >= exams.count {
            return
        }
        let examObject = exams[tableView.selectedRow]
        InspectorKits.showProperties(properties: [
            Property(name: "考试名称", value: examObject.name ?? "N/A"),
            Property(name: "课程代码", value: examObject.courseCode ?? "N/A"),
            Property(name: "课程名称", value: examObject.courseName ?? "N/A"),
            Property(name: "课程教师", value: examObject.teacher ?? "N/A"),
            Property(name: "考试时间", value: examObject.getTime()),
            Property(name: "考试地点", value: examObject.location ?? "N/A"),
            Property(name: "席位", value: examObject.seatNo ?? "N/A"),
        ])
    }
    
    func showErrorMessageNormal(errorMsg: String) {
        let errorAlert: NSAlert = NSAlert()
        errorAlert.informativeText = errorMsg
        errorAlert.messageText = "出错啦"
        errorAlert.addButton(withTitle: "嗯")
        errorAlert.alertStyle = NSAlert.Style.critical
        errorAlert.beginSheetModal(for: view.window!)
    }

    func showInformativeMessage(infoMsg: String) {
        let infoAlert: NSAlert = NSAlert()
        infoAlert.informativeText = infoMsg
        infoAlert.messageText = "提醒"
        infoAlert.addButton(withTitle: "嗯")
        infoAlert.alertStyle = NSAlert.Style.informational
        infoAlert.beginSheetModal(for: view.window!)
    }
    
    override func viewDidAppear() {
        if exams.count == 0 {
            openYearTermSelectionPanel()
        }
        updateTableViewContents()
        super.viewDidAppear()
    }
    
    func openYearTermSelectionPanel() {
        sheetViewController.successDelegate = self
        sheetViewController.requestType = .exam
        presentAsSheet(sheetViewController)
        sheetViewController.enableUI()
    }
    
    func updateTableViewContents() {
        if exams.count == 0 {
            promptTextField.stringValue = "目前没有任何考试安排。"
            view.window?.makeFirstResponder(blurredView)
            blurredView.blurRadius = 3.0
            blurredView.isHidden = false
            TBSyncButton.isHidden = true
            return
        }

        blurredView.isHidden = true
        TBSyncButton.isHidden = false
        blurredView.blurRadius = 0.0

        promptTextField.isEnabled = true
        promptTextField.stringValue = "现有 \(exams.count) 项考试安排。"
        tableView.reloadData()
    }
    
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var promptTextField: NSTextField!
    @IBOutlet weak var blurredView: RMBlurredView!
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
            if self.view.window == nil {
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
    
    @IBAction func restartAnalyse(_ sender: NSButton) {
        exams.removeAll()
        tableView.reloadData()
        updateTableViewContents()
        openYearTermSelectionPanel()
    }

    
    func disableUI() {
//        testInfo.isEnabled = false
        tableView.isEnabled = false
        syncTo.isEnabled = false
        calendarName.isEnabled = false
        getRandomName.isEnabled = false
        remindMe.isEnabled = false
        startSync.isEnabled = false
    }
    
    func resumeUI() {
//        testInfo.isEnabled = true
        tableView.isEnabled = true
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
    
    
    // MARK: - NSTableViewDelegate and NSTableViewDataSource

    func numberOfRows(in tableView: NSTableView) -> Int {
        return exams.count
    }

    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        guard let sortDescriptor = tableView.sortDescriptors.first else {
            return
        }
        //        NSLog(sortDescriptor.key ?? "badSortArgument")
        //        NSLog("now ascending == \(sortDescriptor.ascending)")
        sortArray(sortDescriptor.key ?? "badSortArgument", !sortDescriptor.ascending)
    }
    
    fileprivate enum CellIdentifiers {
        static let CourseCell = "CourseIdCell"
        static let ExamCell = "ExamNameCell"
        static let TimeCell = "TimeCell"
        static let RoomCell = "RoomIdCell"
        static let SeatCell = "SeatCell"
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if row >= exams.count {
            return nil
        }

        var text: String = ""
        var cellIdentifier: String = ""

        let item = exams[row]

        if tableColumn == tableView.tableColumns[0] {
            text = item.courseName ?? "考试科目"
            cellIdentifier = CellIdentifiers.CourseCell
//        } else if tableColumn == tableView.tableColumns[1] {
//            text = item.name ?? "考试名称"
//            cellIdentifier = CellIdentifiers.ExamCell
        } else if tableColumn == tableView.tableColumns[1] {
            text = item.originalTime ?? "未知"
            cellIdentifier = CellIdentifiers.TimeCell
        } else if tableColumn == tableView.tableColumns[2] {
            text = item.location ?? "考试地点"
            cellIdentifier = CellIdentifiers.RoomCell
        } else if tableColumn == tableView.tableColumns[3] {
            text = item.seatNo ?? "座位号"
            cellIdentifier = CellIdentifiers.SeatCell
        }

        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
}
