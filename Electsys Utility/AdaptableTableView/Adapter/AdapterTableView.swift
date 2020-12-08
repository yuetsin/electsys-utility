//
//  AdapterTableView.swift
//  TableView
//
//  Created by Alberto Moral on 07/10/2017.
//  Copyright © 2017 Alberto Moral. All rights reserved.
//

import Cocoa

class AdapterTableView: NSObject {
    fileprivate static let columns = ["nameColumn", "valueColumn"]
    fileprivate static let heightOfRow: CGFloat = 18.0
    
    fileprivate var items: [Property] = [Property]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var tableView: NSTableView
    
    init(tableView: NSTableView) {
        self.tableView = tableView
        super.init()
        self.tableView.dataSource = self
        self.tableView.delegate = self
//        self.tableView.usesAlternatingRowBackgroundColors = true
        self.tableView.backgroundColor = .clear
    }
        
    func add(items: [Property]) {
        self.items += items
    }
}

extension AdapterTableView: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        if tableColumn?.identifier.rawValue == "nameColumn" {
            let name = items[row].name
            let view = NSTextField(string: name)
            view.isEditable = false
            view.isBordered = false
            view.backgroundColor = .clear
            view.textColor = .secondaryLabelColor
            view.alignment = .right
            return view
        } else if tableColumn?.identifier.rawValue == "valueColumn" {
            let value = items[row].value
            let view = NSTextField(string: value)
            view.isEditable = false
            view.isBordered = false
            view.backgroundColor = .clear
            view.lineBreakMode = .byTruncatingTail
            return view
        } else {
            let error = "???"
            let view = NSTextField(string: error)
            view.isEditable = false
            view.isBordered = false
            view.backgroundColor = .clear
            return view
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return AdapterTableView.heightOfRow * 1.2
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        tableView.deselectAll(tableView)
        return true
    }
}
