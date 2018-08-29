//
//  ViewController.swift
//  courseSync
//
//  Created by yuxiqian on 2018/8/29.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Cocoa
import Alamofire

class MainViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        updateCaptcha(refreshCaptchaButton)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBOutlet weak var userNameField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    @IBOutlet weak var captchaTextField: NSTextField!
    @IBOutlet weak var captchaImage: NSImageView!
    @IBOutlet weak var loginButton: NSButton!
    @IBOutlet weak var refreshCaptchaButton: NSButton!
    
    @IBAction func loginButtonClicked(_ sender: NSButton) {
        attemptLogin()
    }
    
    @IBAction func updateCaptcha(_ sender: NSButton) {
        Alamofire.request(captchaUrl).responseData { response in
            let captchaImageObject = NSImage(data: response.data!)
            self.captchaImage.image = captchaImageObject
        }
    }
}

