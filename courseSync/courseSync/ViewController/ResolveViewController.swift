//
//  ResolveViewController.swift
//  Sync Utility
//
//  Created by yuxiqian on 2018/8/31.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Cocoa

class ResolveViewController: NSViewController {

    var dayArray: [SchoolDay] = []
    var htmlDoc: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        for i in 0...6 {
            dayArray.append(SchoolDay(dayNum: i))
        }
//        print(self.htmlDoc)
        initializeInfo()
//        outlineView.reloadData()
    }
    
    @IBOutlet weak var outlineView: NSOutlineView!
    
    @IBAction func extractAll(_ sender: NSButton) {
        outlineView.expandItem(nil, expandChildren: true)
    }
    
    func initializeInfo() {
        parseCourseSheet(htmlDoc, array: &dayArray)
        outlineView.reloadData()
    }
}

extension ResolveViewController: NSOutlineViewDataSource {
    func numberOfRows(in outlineView: NSOutlineView) -> Int {
        return dayArray.count
    }

    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let day = item as? SchoolDay {
            return day.children.count
        }
        return dayArray.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        // judge if it's the day object. if so, it can be expanded.
        return item is SchoolDay
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let day = item as? SchoolDay {
            return day.children[index]
        }
        return dayArray[index]
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
        if item is SchoolDay {
            if tableColumn == outlineView.tableColumns[0] {
                if let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifiers.timeCell), owner: self) as? NSTableCellView {
                    cell.textField?.stringValue = dayOfWeekName[(item as? SchoolDay)?.dayNumber ?? 8]
                    return cell
                }
            }
        } else {
            var displayText = ""
            var identifier = ""
            if tableColumn == outlineView.tableColumns[0] {
                displayText = (item as? Course)?.courseTeacher ?? ""
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
