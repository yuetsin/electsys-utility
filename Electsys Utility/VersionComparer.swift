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
        ESLog.debug("compare version code %@ and %@. Result is %@", versionString, anotherVersionString, (versionA > versionB).description)
        return versionA > versionB
    }
}
