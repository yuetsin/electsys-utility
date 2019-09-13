//
//  TermSelectingViewController.swift
//  Electsys Utility
//
//  Created by 法好 on 2019/9/11.
//  Copyright © 2019 yuxiqian. All rights reserved.
//

import Cocoa

class TermSelectingViewController: NSViewController {
    
    
    @IBOutlet weak var yearPopUpSelector: NSPopUpButton!
    @IBOutlet weak var termPopUpSelector: NSPopUpButton!
    
    @IBOutlet weak var yearPromptTextField: NSTextField!
    @IBOutlet weak var authenticationPromptTextField: NSTextField!
    @IBOutlet weak var OKButton: NSButton!
    @IBOutlet weak var cancelButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        initPopUpLists()
    }
    
    // MARK: fill the year pop up box with meaningful values
    func initPopUpLists() {
        
    }
    
    var successDelegate: YearAndTermSelectionDelegate?
    var failureDelegate: PageNavigationDelegate?
    
    @IBAction func cancelButtonTapped(_ sender: NSButton) {
        
    }
    
    @IBAction func OKButtonTapped(_ sender: NSButton) {
        
    }
    
    @IBAction func yearPopUpButtonTapped(_ sender: NSPopUpButton) {
        
    }
}

protocol YearAndTermSelectionDelegate {
    func successCourseDataTransfer(data: [Course]) -> ()
    func successExamDataTransfer(data: [Exam]) -> ()
    func successScoreDataTransfer(data: [String/* TODO: Add Score Class */]) -> ()
}

protocol PageNavigationDelegate {
    func failureBackToLoginPage() -> ()
}
