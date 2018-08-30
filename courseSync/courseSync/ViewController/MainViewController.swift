//
//  ViewController.swift
//  courseSync
//
//  Created by yuxiqian on 2018/8/29.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Cocoa
import Alamofire

class MainViewController: NSViewController, requestHtmlDelegate {
    
    func validateLoginResult(htmlData: String) {
        NSLog(htmlData)
        if (htmlData.contains("上海交通大学教学信息服务网－学生服务平台")) {
            // success!
        } else if (htmlData.contains("上海交通大学统一身份认证")) {
            showErrorMessage(errorMsg: "登陆失败。\n\n用户名、密码和验证码中有至少一项不正确。")
            resumeUI()
        } else if (!htmlData.isEmpty) {
            showErrorMessage(errorMsg: "登陆失败。\n\n请求的参数不正确。")
            resumeUI()
        } else {
            showErrorMessage(errorMsg: "登陆失败。\n\n检查你的网络连接。")
            resumeUI()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateCaptcha(refreshCaptchaButton)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func disableUI() {
        userNameField.isEnabled = false
        passwordField.isEnabled = false
        captchaTextField.isEnabled = false
        loginButton.isEnabled = false
        refreshCaptchaButton.isEnabled = false
    }
    
    func resumeUI() {
        userNameField.isEnabled = true
        passwordField.isEnabled = true
        captchaTextField.isEnabled = true
        loginButton.isEnabled = true
        refreshCaptchaButton.isEnabled = true
        updateCaptcha(refreshCaptchaButton)
    }

    @IBOutlet weak var userNameField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    @IBOutlet weak var captchaTextField: NSTextField!
    @IBOutlet weak var captchaImage: NSImageView!
    @IBOutlet weak var loginButton: NSButton!
    @IBOutlet weak var refreshCaptchaButton: NSButton!
    
    @IBAction func loginButtonClicked(_ sender: NSButton) {
        let accountParams = [self.userNameField.stringValue, self.passwordField.stringValue, self.captchaTextField.stringValue]
        disableUI()
        let loginSession = Login()
        loginSession.delegate = self
        DispatchQueue.global().async {
            loginSession.attempt(userName: accountParams[0], password: accountParams[1], captchaWord: accountParams[2])
        }
//        case .successLogin:
//            // Byebye, login page
//            break
//        case .accountError:
//            showErrorMessage(errorMsg: "登入失败。\n\n请检查用户名、密码和验证码后重试。")
//            resumeUI()
//            break
//        case .argumentError:
//            showErrorMessage(errorMsg: "登入失败。\n\n传入参数错误。")
//            resumeUI()
//            break
//        case .networkError:
//            showErrorMessage(errorMsg: "登入失败。\n\n网络请求出错。")
//            resumeUI()
//            break
//        }
    }
    
    @IBAction func updateCaptcha(_ sender: NSButton) {
        Alamofire.request(captchaUrl).responseData { response in
            let captchaImageObject = NSImage(data: response.data!)
            if captchaImageObject != nil {
                self.captchaImage.image = captchaImageObject
            } else {
                self.showErrorMessage(errorMsg: "未能成功加载验证码图片。")
            }
        }
    }
    
    func showErrorMessage(errorMsg: String) {
        let errorAlert: NSAlert = NSAlert()
        errorAlert.messageText = errorMsg
        errorAlert.alertStyle = NSAlert.Style.critical
        errorAlert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
}

