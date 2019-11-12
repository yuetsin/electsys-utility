//
//  TermSelectingViewController.swift
//  Electsys Utility
//
//  Created by 法好 on 2019/9/11.
//  Copyright © 2019 yuxiqian. All rights reserved.
//

import Cocoa

class TermSelectingViewController: NSViewController {
    @IBOutlet var yearPopUpSelector: NSPopUpButton!
    @IBOutlet var termPopUpSelector: NSPopUpButton!

    @IBOutlet var yearPromptTextField: NSTextField!
    @IBOutlet var OKButton: NSButton!
    @IBOutlet var cancelButton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        initPopUpLists()
    }

    override func viewDidAppear() {
        // any additional code
        view.window!.styleMask.remove(.resizable)
    }

    func disableUI() {
        yearPopUpSelector.isEnabled = false
        termPopUpSelector.isEnabled = false
        OKButton.isEnabled = false
        cancelButton.isEnabled = false
    }

    func enableUI() {
        yearPopUpSelector.isEnabled = true
        termPopUpSelector.isEnabled = true
        OKButton.isEnabled = true
        cancelButton.isEnabled = true
    }

    var requestType: RequestType?

    // MARK: fill the year pop up box with meaningful values

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
    }

    func showErrorMessage(errorMsg: String) {
        let errorAlert: NSAlert = NSAlert()
        errorAlert.messageText = "出错啦"
        errorAlert.informativeText = errorMsg
        errorAlert.addButton(withTitle: "嗯")
        errorAlert.alertStyle = NSAlert.Style.critical
        errorAlert.beginSheetModal(for: view.window!, completionHandler: nil)
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
