//
//  ResolveViewController.swift
//  Sync Utility
//
//  Created by yuxiqian on 2018/8/31.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Cocoa

class ResolveViewController: NSViewController {
    
    var htmlDoc: String = ""
    
    var weekNum = 0
    
    var schoolTerm = Term(isSummerTerm: false)

    override func viewDidLoad() {

        super.viewDidLoad()
        // Do view setup here.
        
//        print(self.htmlDoc)
        initializeInfo()
//        outlineView.reloadData()
    }
    
    @IBOutlet weak var outlineView: NSOutlineView!
    
    @IBAction func extractAll(_ sender: NSButton) {
        outlineView.expandItem(nil, expandChildren: true)
    }
    
    func initializeInfo() {
        parseCourseSheet(htmlDoc, week: &schoolTerm.weeks[weekNum])
        outlineView.reloadData()
    }
}

extension ResolveViewController: NSOutlineViewDataSource {
    func numberOfRows(in outlineView: NSOutlineView) -> Int {
        return schoolTerm.weeks[weekNum].days.count
    }

    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let day = item as? Day {
            return day.children.count
        }
        return schoolTerm.weeks[weekNum].days.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        // judge if it's the day object. if so, it can be expanded.
        return item is Day
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let day = item as? Day {
            return day.children[index]
        }
        return schoolTerm.weeks[weekNum].days[index]
    }
}

extension ResolveViewController: NSOutlineViewDelegate {
    
    fileprivate enum CellIdentifiers {
        static let timeCell = "timeCell"
        static let nameCell = "nameCell"
        static let teacherCell = "teacherCell"
        static let roomCell = "roomCell"
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if item is Day {
            if tableColumn == outlineView.tableColumns[0] {
                if let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifiers.timeCell), owner: self) as? NSTableCellView {
                    cell.textField?.stringValue = dayOfWeekName[(item as? Day)?.dayNumber ?? 8]
                    return cell
                }
            }
        } else {
            var displayText = ""
            var identifier = ""
            if tableColumn == outlineView.tableColumns[0] {
                let course = item as? Course
                displayText =  defaultLessonTime[(course?.courseStartsAt)!].getString() + "~" + defaultLessonTime[(course?.courseStartsAt)! + (course?.courseDuration)! - 1].getString(passed: durationOfLesson)
                identifier = CellIdentifiers.timeCell
            } else if tableColumn == outlineView.tableColumns[1] {
                displayText = (item as? Course)?.courseRoom ?? ""
                identifier = CellIdentifiers.roomCell
            } else if tableColumn == outlineView.tableColumns[2] {
                displayText = (item as? Course)?.courseTeacher ?? ""
                identifier = CellIdentifiers.teacherCell
            } else if tableColumn == outlineView.tableColumns[3] {
                displayText = (item as? Course)?.courseName ?? ""
                identifier = CellIdentifiers.nameCell
            }
            if let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: identifier), owner: self) as? NSTableCellView {
                cell.textField?.stringValue = displayText
                return cell
            }
        }
        return nil
    }
}
