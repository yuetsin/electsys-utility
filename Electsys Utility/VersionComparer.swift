//
//  VersionComparer.swift
//  Electsys Utility
//
//  Created by 法好 on 2019/9/19.
//  Copyright © 2019 yuxiqian. All rights reserved.
//

import Foundation
import Version

@objc open class VersionComparer: NSObject {
    @objc static func compare(_ version: NSString, isNewerThanVersion: NSString) -> Bool {
        let versionString = String(version).replacingOccurrences(of: "v", with: "")
        let anotherVersionString = String(isNewerThanVersion).replacingOccurrences(of: "v", with: "")
        guard let versionA = Version(versionString) else {
            return true
        }
        guard let versionB = Version(anotherVersionString) else {
            return false
        }
        NSLog("Compare version code \(versionA) and \(versionB). Result is \(versionA > versionB)")
        return versionA > versionB
    }
}
