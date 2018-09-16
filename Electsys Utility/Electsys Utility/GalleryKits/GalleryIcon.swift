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
        return NSColor(red: 235/255.0, green: 237/255.0, blue: 240/255.0, alpha: 1)
    case "light":
        return NSColor(red: 204/255.0, green: 226/255.0, blue: 149/255.0, alpha: 1)
    case "medium":
        return NSColor(red: 141/255.0, green: 198/255.0, blue: 121/255.0, alpha: 1)
    case "heavy":
        return NSColor(red: 75/255.0, green: 151/255.0, blue: 71/255.0, alpha: 1)
    case "full":
        return NSColor(red: 48/255.0, green: 95/255.0, blue: 46/255.0, alpha: 1)
    default:
        return NSColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
    }
}
