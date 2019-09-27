//
//  TableView.swift
//  TableView
//
//  Created by Alberto Moral on 07/10/2017.
//  Copyright © 2017 Alberto Moral. All rights reserved.
//

import Cocoa

class TableView: BaseView {
    var scrollViewTableView = NSScrollView()
    
    var stackView: NSStackView = {
        var textField = NSTextField()
        var exportButton = NSButton()
        textField.isEditable = false
        textField.isSelectable = false
        textField.isBordered = false
        textField.backgroundColor = .clear
        textField.stringValue = "共有 0 项属性可供检查。"
        textField.textColor = .secondaryLabelColor
        
        var font = NSFont(name: "System", size: 11.0)
        textField.font = font
        
        
        exportButton.bezelStyle = .roundRect
        exportButton.controlSize = .mini
        exportButton.title = "导出"
        exportButton.font = font
        
        let stackView = NSStackView(frame: .zero)
        stackView.addView(textField, in: .center)
        stackView.addView(exportButton, in: .center)
        stackView.orientation = .horizontal
        
        stackView.edgeInsets = NSEdgeInsets(top: 4.0, left: 8.0, bottom: 4.0, right: 8.0)
        return stackView
    }()

    var tableView: NSTableView = {
        let table = NSTableView(frame: .zero)
//        table.rowSizeStyle = .large
        table.backgroundColor = .clear

        let nameColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "nameColumn"))
        table.headerView = nil
        nameColumn.width = 70
        table.addTableColumn(nameColumn)
        
        let valueColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "valueColumn"))
        table.headerView = nil
        valueColumn.width = 1
        table.addTableColumn(valueColumn)
        
        return table
    }()

    override func addSubviews() {
        scrollViewTableView.documentView = tableView
        [scrollViewTableView, stackView].forEach(addSubview)
    }

    override func addConstraints() {
        scrollViewTableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([scrollViewTableView.topAnchor.constraint(equalTo: scrollViewTableView.superview!.topAnchor),
                                     scrollViewTableView.leadingAnchor.constraint(equalTo: scrollViewTableView.superview!.leadingAnchor),
                                     scrollViewTableView.trailingAnchor.constraint(equalTo: scrollViewTableView.superview!.trailingAnchor),
                                     scrollViewTableView.bottomAnchor.constraint(equalTo: stackView.topAnchor),
        ])
        
        stackView.translatesAutoresizingMaskIntoConstraints = false;
        
        NSLayoutConstraint.activate([stackView.topAnchor.constraint(equalTo: scrollViewTableView.bottomAnchor),
                                     stackView.leadingAnchor.constraint(equalTo: stackView.superview!.leadingAnchor),
                                     stackView.trailingAnchor.constraint(equalTo: stackView.superview!.trailingAnchor),
                                     stackView.bottomAnchor.constraint(equalTo: stackView.superview!.bottomAnchor),
        ])
    }
}
