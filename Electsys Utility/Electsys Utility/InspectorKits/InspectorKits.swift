//
//  InspectorKits.swift
//  Electsys Utility
//
//  Created by 法好 on 2019/9/16.
//  Copyright © 2019 yuxiqian. All rights reserved.
//

import Foundation

class InspectorKits {
    
    static var window: NSWindow?
    
    static func showProperties(properties: [Property]) {
        
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("InspectorWindowController")) as! NSWindowController

        InspectorKits.window = windowController.window
        if InspectorKits.window != nil {
            (window?.contentViewController as! TableViewController).configureTableView(properties: properties)
            windowController.showWindow(self)
        }
    }
}
