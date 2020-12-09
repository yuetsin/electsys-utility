//
//  CookieParserViewController.swift
//  Electsys Utility
//
//  Created by 法好 on 2020/12/8.
//  Copyright © 2020 yuxiqian. All rights reserved.
//

import Alamofire
import Cocoa

class CookieParserViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    var delegate: WebLoginDelegate?

    @IBOutlet var textField: NSTextView!

    @IBAction func giveUpLogin(_ sender: NSButton) {
        done(success: false)
    }

    @IBAction func completeLogin(_ sender: NSButton) {
        let dict = parseCookies(rawString: textField.string)
        let targetUrl = URL(string: LoginConst.initUrl)!
        
        for pair in dict {
            ESLog.info("parsed cookie pair: \(pair.key) : \(pair.value)")
        }
        
        for cookie in HTTPCookie.cookies(withResponseHeaderFields: dict, for: targetUrl) {
            Alamofire.HTTPCookieStorage.shared.setCookie(cookie)
        }
        done(success: true)
    }

    func done(success: Bool = true) {
        delegate?.callbackCookie(success)
    }
}

func parseCookies(rawString: String) -> [String: String] {
    return rawString.split(separator: ";").map { chars -> Substring in
        chars.drop(while: { (char: Character) in // Trim leading spaces
            char == " "
        })
    }.reduce([String: String]()) { (dict, chars) -> [String: String] in
        let pair = chars.split(separator: "=")
        guard let name = pair.first, let value = pair.indices.contains(1) ? pair[1] : nil else {
            return dict
        }
        var d = dict
        d[String(name)] = String(value)
        return d
    }
}
