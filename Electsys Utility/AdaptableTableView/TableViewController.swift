//
//  TableViewViewController.swift
//  TableView
//
//  Created by Alberto Moral on 07/10/2017.
//  Copyright © 2017 Alberto Moral. All rights reserved.
//

import Cocoa

class TableViewController: NSViewController {
    var mainView: TableView { return view as! TableView }
    fileprivate var adapter: AdapterTableView?

    // MARK: View Controller

    override func loadView() {
        let rect = NSRect(x: 0, y: 0, width: 300, height: 400)
        view = TableView(frame: rect)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func configureTableView(properties: [Property]) {
        adapter = AdapterTableView(tableView: mainView.tableView)
        adapter?.add(items: properties)
        view.window?.title = "属性检查器：\(properties.count) 项"
    }
}
