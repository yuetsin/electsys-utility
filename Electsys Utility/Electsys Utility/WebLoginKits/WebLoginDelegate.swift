//
//  WebLoginDelegate.swift
//  Electsys Utility
//
//  Created by 法好 on 2020/12/8.
//  Copyright © 2020 yuxiqian. All rights reserved.
//

import Foundation

protocol WebLoginDelegate {
    func callbackWeb(_: Bool) -> ()
    func callbackCookie(_: Bool) -> ()
}
