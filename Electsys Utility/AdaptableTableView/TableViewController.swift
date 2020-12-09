//
//  TableViewViewController.swift
//  TableView
//
//  Created by Alberto Moral on 07/10/2017.
//  Copyright © 2017 Alberto Moral. All rights reserved.
//

import Cocoa
import CSV

class TableViewController: NSViewController, ExportFormatDecisionDelegate {
    
    var mainView: TableView { return view as! TableView }
    fileprivate var adapter: AdapterTableView?

    @IBOutlet weak var contentView: NSView!

    // MARK: View Controller

    override func loadView() {
        let rect = NSRect(x: 0, y: 0, width: 300, height: 400)
        view = TableView(frame: rect)
    }
    
    var propertiesEntry: [Property] = []

    let addMyPopover = NSPopover()
    
    @IBAction func exportButtonClicked(_ sender: NSButton) {
        if propertiesEntry.count == 0 {
            return
        }

        let popOverController = ExportFormatSelector()
        popOverController.delegate = self
        addMyPopover.behavior = .transient
        addMyPopover.contentViewController = popOverController
        addMyPopover.contentSize = CGSize(width: 250, height: 140)
        addMyPopover.show(relativeTo: sender.bounds, of: sender, preferredEdge: NSRectEdge.minY)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showErrorMessageNormal(errorMsg: String) {
        let errorAlert: NSAlert = NSAlert()
        errorAlert.informativeText = errorMsg
        errorAlert.messageText = "出错啦"
        errorAlert.addButton(withTitle: "嗯")
        errorAlert.alertStyle = NSAlert.Style.critical
        errorAlert.beginSheetModal(for: view.window!)
        ESLog.error("error occured. internal message: ", errorMsg)
    }

    func showInformativeMessage(infoMsg: String) {
        let infoAlert: NSAlert = NSAlert()
        infoAlert.informativeText = infoMsg
        infoAlert.messageText = "提醒"
        infoAlert.addButton(withTitle: "嗯")
        infoAlert.alertStyle = NSAlert.Style.informational
        infoAlert.beginSheetModal(for: view.window!)
        ESLog.info("informative message thrown. message: ", infoMsg)
    }

    func configureTableView(properties: [Property]) {
        adapter = AdapterTableView(tableView: mainView.tableView)
        adapter?.add(items: properties)
        (mainView.stackView.views[0] as! NSTextField).stringValue = "共有 \(properties.count) 项属性可供检查。"
        (mainView.stackView.views[1] as! NSButton).action = #selector(exportButtonClicked(_:))
        propertiesEntry = properties
    }
    
    func exportPlainText() {
        let csv = try! CSVWriter(stream: .toMemory())

        try! csv.write(row: ["属性名称", "属性值"])

        for prop in propertiesEntry {
            try! csv.write(row: [prop.name, prop.value])
        }
        csv.stream.close()
        let csvData = csv.stream.property(forKey: .dataWrittenToMemoryStreamKey) as! Data
        let textString = String(data: csvData, encoding: .utf8)!

        let panel = NSSavePanel()
        panel.title = "保存 CSV 格式属性列表"
        panel.message = "请选择 CSV 格式属性列表的保存路径。"

        panel.nameFieldStringValue = "PropertiesList"
        panel.allowsOtherFileTypes = false
        panel.allowedFileTypes = ["csv", "txt"]
        panel.isExtensionHidden = false
        panel.canCreateDirectories = true

        panel.beginSheetModal(for: view.window!, completionHandler: { result in
            do {
                if result == NSApplication.ModalResponse.OK {
                    if let path = panel.url?.path {
                        try textString.write(toFile: path, atomically: true, encoding: .utf8)
                        self.showInformativeMessage(infoMsg: "已经成功导出 CSV 格式属性列表。")
                    } else {
                        return
                    }
                }
            } catch {
                self.showErrorMessageNormal(errorMsg: "无法导出 CSV 格式属性列表。")
            }
        })
    }
    
    func exportJSONFormat() {
        addMyPopover.performClose(self)
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(propertiesEntry)
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
            let panel = NSSavePanel()
            panel.title = "保存属性列表"
            panel.message = "请选择 JSON 格式属性列表的保存路径。"

            panel.nameFieldStringValue = "PropertiesList"
            panel.allowsOtherFileTypes = false
            panel.allowedFileTypes = ["json"]
            panel.isExtensionHidden = false
            panel.canCreateDirectories = true

            panel.beginSheetModal(for: view.window!, completionHandler: { result in
                do {
                    if result == NSApplication.ModalResponse.OK {
                        if let path = panel.url?.path {
                            try jsonString?.write(toFile: path, atomically: true, encoding: .utf8)
                            self.showInformativeMessage(infoMsg: "已经成功导出 JSON 格式的属性列表。")
                        } else {
                            return
                        }
                    }
                } catch {
                    self.showErrorMessageNormal(errorMsg: "无法导出 JSON 表示的属性列表。")
                }
            })
        } catch {
            showErrorMessageNormal(errorMsg: "无法导出 JSON 表示的属性列表。")
        }
    }
}
