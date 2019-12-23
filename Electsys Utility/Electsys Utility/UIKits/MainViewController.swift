//
//  MainViewController.swift
//  Electsys Utility
//
//  Created by yuxiqian on 2018/12/27.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, NSSplitViewDelegate, UIManagerDelegate {
    
    override func viewDidLoad() {
        if #available(OSX 10.12.2, *) {
            ESLog.info("system version >= 10.12.2, ok")
        } else {
            ESLog.error("critical! bad system version")
            let alert = NSAlert()
            alert.messageText = "系统版本不合"
            alert.informativeText = "Electsys Utility 至少需要 macOS 10.12.2 以正常运行。\nApp 即将退出。"
            alert.addButton(withTitle: "行")
            alert.alertStyle = .critical
            alert.runModal()
            NSApplication.shared.terminate(nil)
        }
        super.viewDidLoad()
        // Do view setup here.
        registerDelegate()
        lockIcon()
        setAccessibilityLabel()
        self.view.window?.makeFirstResponder(aboutButton)
        
        aboutButton.image?.isTemplate = true
        preferenceButton.image?.isTemplate = true
        creditsButton.image?.isTemplate = true
        
        loginJAccountButton.image?.isTemplate = true
        syncCourseTableButton.image?.isTemplate = true
        syncTestInfoButton.image?.isTemplate = true
        getScoreButton.image?.isTemplate = true
        
        insertHtmlButton.image?.isTemplate = true
        queryLibraryButton.image?.isTemplate = true
        reportIssueButton.image?.isTemplate = true
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
    }
    
    fileprivate func registerDelegate() {
        splitView.delegate = self
    }
    
    func setAccessibilityLabel() {
        tabViewController?.children[0].view.setAccessibilityParent(aboutButton)
        tabViewController?.children[1].view.setAccessibilityParent(preferenceButton)
        tabViewController?.children[2].view.setAccessibilityParent(creditsButton)
        tabViewController?.children[3].view.setAccessibilityParent(loginJAccountButton)
        tabViewController?.children[4].view.setAccessibilityParent(syncCourseTableButton)
        tabViewController?.children[5].view.setAccessibilityParent(syncTestInfoButton)
        tabViewController?.children[6].view.setAccessibilityParent(getScoreButton)
        tabViewController?.children[7].view.setAccessibilityParent(insertHtmlButton)
        tabViewController?.children[8].view.setAccessibilityParent(queryLibraryButton)
        tabViewController?.children[9].view.setAccessibilityParent(reportIssueButton)
        
        aboutButton.setAccessibilityLabel("切换到关于窗格")
        preferenceButton.setAccessibilityLabel("切换到偏好设置窗格")
        creditsButton.setAccessibilityLabel("切换到致谢窗格")
        
        loginJAccountButton.setAccessibilityLabel("切换到 jAccount 登录窗格")
        syncCourseTableButton.setAccessibilityLabel("切换到课程表同步窗格")
        syncTestInfoButton.setAccessibilityLabel("切换到考试信息同步窗格")
        getScoreButton.setAccessibilityLabel("切换到成绩查询窗格")
        
        insertHtmlButton.setAccessibilityLabel("切换到离线同步窗格")
        queryLibraryButton.setAccessibilityLabel("切换到查询课程库窗格")
        reportIssueButton.setAccessibilityLabel("切换到问题报告窗格")
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        // Prepare for segue
        tabViewController = segue.destinationController as? MainTabViewController
    }
    
    @IBOutlet var splitView: NSSplitView!
    @IBOutlet weak var containerView: NSView!
    
    @IBOutlet weak var aboutButton: NSButton!
    @IBOutlet weak var preferenceButton: NSButton!
    @IBOutlet weak var creditsButton: NSButton!
    @IBOutlet weak var loginJAccountButton: NSButton!
    @IBOutlet weak var syncCourseTableButton: NSButton!
    @IBOutlet weak var syncTestInfoButton: NSButton!
    @IBOutlet weak var getScoreButton: NSButton!
    @IBOutlet weak var insertHtmlButton: NSButton!
    @IBOutlet weak var queryLibraryButton: NSButton!
    @IBOutlet weak var reportIssueButton: NSButton!
    
    
    private var tabViewController: MainTabViewController?
    
    @IBAction func switchFeature(_ sender: NSButton) {
        
        aboutButton.state = .off
        preferenceButton.state = .off
        creditsButton.state = .off
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
        
        self.view.window?.makeFirstResponder(sender)
        
        tabViewController?.children[sender.tag].becomeFirstResponder()
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
    
    func unlockIcon() {
        loginJAccountButton.image = NSImage(imageLiteralResourceName: "NSLockUnlockedTemplate")
        syncCourseTableButton.isEnabled = true
        syncTestInfoButton.isEnabled = true
        getScoreButton.isEnabled = true
    }
    
    func lockIcon() {
        loginJAccountButton.image = NSImage(imageLiteralResourceName: "NSLockLockedTemplate")
        syncCourseTableButton.isEnabled = false
        syncTestInfoButton.isEnabled = false
        getScoreButton.isEnabled = false
        self.view.window?.makeFirstResponder(aboutButton)
    }
    
    func visitAboutPage() {
        switchToPage(index: 0)
    }
    
    func visitPrefPage() {
        switchToPage(index: 1)
    }
    
    func visitCreditsPage() {
        switchToPage(index: 2)
    }
    
    func switchToPage(index: Int) {
        aboutButton.state = .off
        preferenceButton.state = .off
        creditsButton.state = .off
        loginJAccountButton.state = .off
        syncCourseTableButton.state = .off
        syncTestInfoButton.state = .off
        getScoreButton.state = .off
        insertHtmlButton.state = .off
        queryLibraryButton.state = .off
        reportIssueButton.state = .off
        
        (self.view.viewWithTag(index) as! NSButton).state = .on
        
        if tabViewController == nil {
            return
        }
        
        self.view.window?.makeFirstResponder(self.view.viewWithTag(index) as! NSButton)
    
        tabViewController?.tabView.selectTabViewItem(at: index)
        tabViewController?.children[index].becomeFirstResponder()
    }
}


protocol UIManagerDelegate: NSObjectProtocol {
    func unlockIcon() -> ()
    func lockIcon() -> ()
    func switchToPage(index: Int) -> ()
}

