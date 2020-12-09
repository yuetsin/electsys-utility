//
//  TermSelectingViewController.swift
//  Electsys Utility
//
//  Created by 法好 on 2019/9/11.
//  Copyright © 2019 yuxiqian. All rights reserved.
//

import Cocoa

@available(OSX 10.12.2, *)
class TermSelectingViewController: NSViewController, NSScrubberDataSource, NSScrubberDelegate {
    func numberOfItems(for scrubber: NSScrubber) -> Int {
        return yearPopUpSelector.numberOfItems
    }

    func scrubber(_ scrubber: NSScrubber, viewForItemAt index: Int) -> NSScrubberItemView {
        if index < yearPopUpSelector.numberOfItems {
            let itemView = scrubber.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TextScrubberItemIdentifier"),
                                             owner: nil) as! NSScrubberTextItemView
            itemView.textField.stringValue = yearPopUpSelector.item(at: index)?.title ?? "N/A"
            
            return itemView
        } else {
            let itemView = scrubber.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TextScrubberItemIdentifier"), owner: nil) as! NSScrubberTextItemView
            itemView.textField.stringValue = "N/A"
            return itemView
        }
    }
    
    func scrubber(_ scrubber: NSScrubber, didSelectItemAt index: Int) {
        // Log the index value for the item the user selected
        if index < yearPopUpSelector.numberOfItems {
            yearPopUpSelector.selectItem(at: index)
        }
        syncScrubber()
    }

    @IBOutlet var yearPopUpSelector: NSPopUpButton!
    @IBOutlet var termPopUpSelector: NSPopUpButton!

    @IBOutlet var yearPromptTextField: NSTextField!
    @IBOutlet var OKButton: NSButton!
    @IBOutlet var cancelButton: NSButton!

    @IBOutlet weak var touchBarOkButton: NSButton!
    @IBOutlet weak var touchBarCancelButton: NSButton!
    
    @IBOutlet var yearScrubber: NSScrubber!
    @IBOutlet var termSelector: NSSegmentedControl!
    @IBOutlet weak var popOverTouchBar: NSPopoverTouchBarItem!
    
    @IBAction func cancelTouchBarTapped(_ sender: NSButtonCell) {
        cancelButtonTapped(cancelButton)
    }

    @IBAction func okTouchBarTapped(_ sender: NSButton) {
        OKButtonTapped(OKButton)
    }

    @IBAction func touchBarTermTapped(_ sender: NSSegmentedControl) {
        if sender.selectedSegment < termPopUpSelector.numberOfItems {
            termPopUpSelector.selectItem(at: sender.selectedSegment)
        }
    }

    func syncScrubber() {
        if popOverTouchBar != nil {
            popOverTouchBar.collapsedRepresentationLabel = yearPopUpSelector.selectedItem?.title ?? "N/A"
    //        popOverTouchBar.customizationLabel = yearPopUpSelector.selectedItem?.title ?? "N/A"
            popOverTouchBar.dismissPopover(self)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        initPopUpLists()
        
        if yearScrubber != nil {
            yearScrubber.dataSource = self
            yearScrubber.delegate = self
            yearScrubber.mode = .free
            syncScrubber()
            yearScrubber.register(NSScrubberTextItemView.self, forItemIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TextScrubberItemIdentifier"))
        }
        termPopUpButtonTapped(termPopUpSelector)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window!.styleMask.remove(.resizable)
    }

    func disableUI() {
        yearPopUpSelector.isEnabled = false
        termPopUpSelector.isEnabled = false
        OKButton.isEnabled = false
        cancelButton.isEnabled = false
        
        if touchBarOkButton != nil {
            touchBarOkButton.isEnabled = false
        }
        
        if touchBarCancelButton != nil {
            touchBarCancelButton.isEnabled = false
        }
    }

    func enableUI() {
        yearPopUpSelector.isEnabled = true
        termPopUpSelector.isEnabled = true
        OKButton.isEnabled = true
        cancelButton.isEnabled = true
        
        if touchBarOkButton != nil {
            touchBarOkButton.isEnabled = true
        }
        
        if touchBarCancelButton != nil {
            touchBarCancelButton.isEnabled = true
        }
    }
    

    var requestType: RequestType?

    func initPopUpLists() {
        let date = Date()
        let calendar = Calendar.current
        var year = calendar.component(.year, from: date)

        yearPopUpSelector.removeAllItems()

        if year < 2019 {
            year = 2019
            // fallback as year 2019
        }

        for iteratedYear in (1996 ... year).reversed() {
            yearPopUpSelector.addItem(withTitle: "\(iteratedYear) 至 \(iteratedYear + 1) 学年")
        }

        yearPopUpButtonTapped(yearPopUpSelector)
    }

    var successDelegate: YearAndTermSelectionDelegate?
    var failureDelegate: PageNavigationDelegate?

    @IBAction func cancelButtonTapped(_ sender: NSButton) {
        successDelegate?.shutWindow()
    }

    @IBAction func OKButtonTapped(_ sender: NSButton) {
        disableUI()
        switch requestType {
        case .course:
            let actualYear = 1995 + yearPopUpSelector.numberOfItems - yearPopUpSelector.indexOfSelectedItem
            let actualTerm = termPopUpSelector.indexOfSelectedItem + 1
            CourseKits.requestCourseTable(year: actualYear, term: actualTerm,
                                          handler: { courses in
                                              self.successDelegate?.successCourseDataTransfer(data: courses)
//                                            self.successDelegate?.shutWindow()
                                          },
                                          failure: { errCode in
                                              self.showErrorMessage(errorMsg: "未能获取此学期的课表信息。\n错误代码：\(errCode)")
                                              self.enableUI()
            })
            break
        case .exam:
            let actualYear = 1995 + yearPopUpSelector.numberOfItems - yearPopUpSelector.indexOfSelectedItem
            let actualTerm = termPopUpSelector.indexOfSelectedItem + 1
            ExamKits.requestExamTable(year: actualYear, term: actualTerm,
                                      handler: { exams in
                                          self.successDelegate?.successExamDataTransfer(data: exams)
                                          //                                            self.successDelegate?.shutWindow()
                                      },
                                      failure: { errCode in
                                          self.showErrorMessage(errorMsg: "未能获取此学期的考试信息。\n错误代码：\(errCode)")
                                          self.enableUI()
            })
            break
        case .score:
            let actualYear = 1995 + yearPopUpSelector.numberOfItems - yearPopUpSelector.indexOfSelectedItem
            let actualTerm = termPopUpSelector.indexOfSelectedItem + 1
            ScoreKits.requestScoreData(year: actualYear, term: actualTerm,
                                       handler: { scores in
                                           self.successDelegate?.successScoreDataTransfer(data: scores)
//                                            self.successDelegate?.shutWindow()
                                       },
                                       failure: { errCode in
                                           self.showErrorMessage(errorMsg: "未能获取此学期的成绩单。\n错误代码：\(errCode)")
                                           self.enableUI()
            })
            break
        default:
            break
        }
    }

    @IBAction func yearPopUpButtonTapped(_ sender: NSPopUpButton) {
        let actualYear = 1996 + sender.numberOfItems - sender.indexOfSelectedItem
        yearPromptTextField.stringValue = "指始于 \(actualYear - 1) 年秋季，终于 \(actualYear) 年夏季的学年。"
        yearPopUpSelector.selectItem(at: sender.indexOfSelectedItem)
        syncScrubber()
    }
    
    @IBAction func termPopUpButtonTapped(_ sender: NSPopUpButton) {
        if termSelector != nil {
            termSelector.selectSegment(withTag: sender.indexOfSelectedItem)
        }
    }

    func showErrorMessage(errorMsg: String) {
        let errorAlert: NSAlert = NSAlert()
        errorAlert.messageText = "出错啦"
        errorAlert.informativeText = errorMsg
        errorAlert.addButton(withTitle: "嗯")
        errorAlert.alertStyle = NSAlert.Style.critical
        errorAlert.beginSheetModal(for: view.window!, completionHandler: nil)
        
        ESLog.error("internal error occurred. message: ", errorMsg)
    }
}

protocol YearAndTermSelectionDelegate {
    func successCourseDataTransfer(data: [NGCourse]) -> Void
    func successExamDataTransfer(data: [NGExam]) -> Void
    func successScoreDataTransfer(data: [NGScore]) -> Void
    func shutWindow() -> Void
}

protocol PageNavigationDelegate {
    func failureBackToLoginPage() -> Void
}

enum RequestType {
    case course
    case exam
    case score
}
