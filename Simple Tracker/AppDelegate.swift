//
//  AppDelegate.swift
//  TimeTracker
//
//  Created by Sam Johnson on 12/22/18.
//  Copyright © 2018 Sam Johnson. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationWillFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        // if we have nothing after loading, install defaults
        if ProjectHelper.instance.items.count == 0 {
            ProjectHelper.instance.installDefaults()
        }
        
        openWindow()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        ProjectHelper.instance.save()
        TrackedItemHelper.instance.save()
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            openWindow()
        }
        return true
    }
    
    func openWindow() {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: Bundle.main)
        let window = storyboard.instantiateController(withIdentifier: "MainWindow") as! NSWindowController
        window.showWindow(self)
    }


}

