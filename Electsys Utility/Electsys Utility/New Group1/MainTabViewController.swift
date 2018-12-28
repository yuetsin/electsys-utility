//
//  MainTabViewController.swift
//  Electsys Utility
//
//  Created by yuxiqian on 2018/12/27.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Cocoa

class MainTabViewController: NSTabViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        (self.childViewControllers[3] as! jAccountViewController).UIDelegate = (self.parent as! MainViewController)
        (self.childViewControllers[3] as! jAccountViewController).htmlDelegate = (self.childViewControllers[4] as! ResolveViewController)
    }
    
    @IBOutlet weak var featureTabView: NSTabView!

}
