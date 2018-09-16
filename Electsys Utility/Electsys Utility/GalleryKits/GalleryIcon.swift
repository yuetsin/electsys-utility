//
//  GalleryIcon.swift
//  Electsys Utility
//
//  Created by yuxiqian on 2018/9/16.
//  Copyright © 2018 yuxiqian. All rights reserved.
//

import Foundation
import Cocoa


func getColor(name: String) -> NSColor {
    switch name {
    case "empty":
        return NSColor(red: 235, green: 237, blue: 240, alpha: 1)
    case "light":
        return NSColor(red: 204, green: 226, blue: 149, alpha: 1)
    case "medium":
        return NSColor(red: 141, green: 198, blue: 121, alpha: 1)
    case "heavy":
        return NSColor(red: 75, green: 151, blue: 71, alpha: 1)
    case "full":
        return NSColor(red: 48, green: 95, blue: 46, alpha: 1)
    default:
        return NSColor(red: 255, green: 255, blue: 255, alpha: 1)
    }
}
