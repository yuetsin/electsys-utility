//
//  FullDataViewController.swift
//  Sync Utility
//
//  Created by yuxiqian on 2018/9/5.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Cocoa
import Alamofire

class FullDataViewController: NSViewController, queryDelegate {
    
    var courses: [Curricula] = []
    var teachers: [Teacher] = []
    var toTheEnd: Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        for year in 0...8 {
            yearSelector.addItem(withTitle: ConvertToString(Year(rawValue: 2018 - year)!))
        }
    }
    
    @IBOutlet weak var yearSelector: NSPopUpButton!
    @IBOutlet weak var termSelector: NSPopUpButton!
    @IBOutlet weak var startQuery: NSButton!
    
    @IBAction func startButtonClicked(_ sender: NSButton) {
        let query = Query()
        query.delegate = self
        var bsid = firstBsid
        toTheEnd = false
        DispatchQueue.global().async {
            while !self.toTheEnd {
                DispatchQueue.global().async {
//                    query.start(Bsid: bsid, <#Int#>)
                }
                Thread.sleep(forTimeInterval: 1)
                // 睡十秒钟再说
                bsid += 1
                if bsid % 8 == 0 {
                    Thread.sleep(forTimeInterval: 31)
                    // 每爬 8 个睡 31 秒
                }
            }
        }
    }
    
    func judgeResponse(htmlData: String) {
        if let course = parseCourseDetail(htmlData) {
            course.printToConsole()
            courses.append(course)
        } else {
//            print("被发现了！")
            DispatchQueue.main.async {
                self.toTheEnd = true
            }
        }
    }
}
