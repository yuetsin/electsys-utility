//
//  ESLog.swift
//  Electsys Utility
//
//  Created by 法好 on 2019/12/23.
//  Copyright © 2019 yuxiqian. All rights reserved.
//

import Foundation
import Log

let ESLog = Logger()


//var debugMode = true
let isDebugVersion = false

func enableDebugMode() {
    ESLog.enabled = true
//    debugMode = true
    ESLog.info("eslogger enabled")
}

func disableDebugMode() {
    ESLog.enabled = false
//    debugMode = false
    ESLog.info("eslogger disabled")
}

func initDebugger() {
    enableDebugMode()
    ESLog.minLevel = .error
    ESLog.info("eslogger initialized")
}


