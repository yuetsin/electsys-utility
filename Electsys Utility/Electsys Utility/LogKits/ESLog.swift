//
//  ESLog.swift
//  Electsys Utility
//
//  Created by 法好 on 2019/12/23.
//  Copyright © 2019 yuxiqian. All rights reserved.
//

import Foundation
import os.log

enum ESLogLevel: Int {
    case off = -1
    case debug = 0
    case info = 10
    case error = 20
    case fault = 30
}


class ESLog {

    private static let loggerEntities: [ESLogLevel: OSLog] = [
        ESLogLevel.debug: OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "DEBUG"),
        ESLogLevel.info: OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "INFO"),
        ESLogLevel.error: OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "ERROR"),
        ESLogLevel.fault: OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "FAULT")
    ]
    
    static var minLevel: ESLogLevel = .error
    
    static func debug(_ message: StaticString, _ args: CVarArg...) {
        makeLog(level: .debug, message, args)
    }
    
    static func info(_ message: StaticString, _ args: CVarArg...) {
        makeLog(level: .info, message, args)
    }
    
    static func error(_ message: StaticString, _ args: CVarArg...) {
        makeLog(level: .error, message, args)
    }
    
    static func fault(_ message: StaticString, _ args: CVarArg...) {
        makeLog(level: .fault, message, args)
    }
    
    fileprivate static func makeLog(level: ESLogLevel, _ message: StaticString, _ args: [CVarArg]) {
        if minLevel.rawValue <= level.rawValue && loggerEntities[level] != nil {
            let actualLogger = loggerEntities[level]!
            
            // super ugly hack
            switch args.count {
            case 0:
                os_log(message, log: actualLogger)
            case 1:
                os_log(message, log: actualLogger, args[0])
            case 2:
                os_log(message, log: actualLogger, args[0], args[1])
            case 3:
                os_log(message, log: actualLogger, args[0], args[1], args[2])
            default:
                os_log(message, log: actualLogger, args)
            }
        }
    }
}


func initDebugger() {
    ESLog.info("eslogger initialized")
}


