//
//  MainViewController.swift
//  Electsys Utility
//
//  Created by 法好 on 2018/12/27.
//  Copyright © 2018年 yuxiqian. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, NSSplitViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        splitView.delegate = self
    }
    
    
    
    @IBOutlet var splitView: NSSplitView!
    @IBOutlet weak var containerView: NSView!
    
    @IBOutlet weak var welcomeButton: NSButton!
    @IBOutlet weak var preferenceButton: NSButton!
    @IBOutlet weak var aboutButton: NSButton!
    @IBOutlet weak var loginJAccountButton: NSButton!
    @IBOutlet weak var syncCourseTableButton: NSButton!
    @IBOutlet weak var syncTestInfoButton: NSButton!
    @IBOutlet weak var getScoreButton: NSButton!
    @IBOutlet weak var insertHtmlButton: NSButton!
    @IBOutlet weak var queryLibraryButton: NSButton!
    @IBOutlet weak var reportIssueButton: NSButton!
    
    
    private var tabViewController: MainTabViewController?
    
    @IBAction func switchFeature(_ sender: NSButton) {
        
        welcomeButton.state = .off
        preferenceButton.state = .off
        aboutButton.state = .off
        loginJAccountButton.state = .off
        syncCourseTableButton.state = .off
        syncTestInfoButton.state = .off
        getScoreButton.state = .off
        insertHtmlButton.state = .off
        queryLibraryButton.state = .off
        reportIssueButton.state = .off
    
        if tabViewController == nil {
            return
        }
        tabViewController?.tabView.selectTabViewItem(at: sender.tag)
        sender.state = .on
    
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        tabViewController = segue.destinationController as? MainTabViewController
    }
    
    func splitView(_ splitView: NSSplitView, constrainMinCoordinate proposedMinimumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        return 200
    }
    
    func splitView(_ splitView: NSSplitView, constrainMaxCoordinate proposedMaximumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        return 200
    }
    
    
    func splitView(_ splitView: NSSplitView, resizeSubviewsWithOldSize oldSize: NSSize) {
        let oldWidth: CGFloat = (splitView.arrangedSubviews.first?.frame.size.width)!
        splitView.adjustSubviews()
        splitView.setPosition(oldWidth, ofDividerAt: 0)
    }
}
