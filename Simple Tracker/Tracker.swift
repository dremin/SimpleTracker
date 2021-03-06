//
//  Tracker.swift
//  Simple Tracker
//
//  Created by Sam Johnson on 1/1/19.
//  Copyright © 2019 Sam Johnson. All rights reserved.
//

import Foundation

class Tracker {
    // MARK: Constants
    static let instance = Tracker()
    
    // MARK: Properties
    var isTracking = false
    var timer: Timer?
    var seconds = 0
    var delegate: MainViewController?
    var activity: NSObjectProtocol?
    
    func startTracking() {
        // tell system to keep app alive
        activity = ProcessInfo().beginActivity(options: .userInitiated, reason: "Timer running")
        
        isTracking = true
        
        delegate?.updateButton()
        
        // start timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            self.seconds += 1
            self.delegate?.updateButton()
        }
        
        timer?.fire()
    }
    
    func stopTracking(project: String, notes: String) {
        // stop system activity to allow sleep
        if let procinfo = activity {
            ProcessInfo().endActivity(procinfo)
        }
        
        isTracking = false
        
        timer?.invalidate()
        
        let newItem = TrackedItem(project: ProjectHelper.instance.getProject(name: project)?.id ?? 0, notes: notes, seconds: seconds);
        TrackedItemHelper.instance.items.append(newItem)
        TrackedItemHelper.instance.sort()
        
        // reset state
        delegate?.updateButton()
        delegate?.clearNotes()
        seconds = 0
        timer = nil
        
        // save
        TrackedItemHelper.instance.save()
        
        // update table
        delegate?.updateTable(TrackedItemHelper.instance.items.firstIndex{$0 === newItem} ?? TrackedItemHelper.instance.items.count - 1)
    }
    
    func secondsString() -> String {
        var display = ""
        
        if seconds >= 3600 {
            // hours
            display += String(format: "%02d", seconds / 3600) + ":"
        }
        
        // minutes
        display += String(format: "%02d", (seconds % 3600) / 60) + ":"
        
        // seconds
        display += String(format: "%02d", (seconds % 3600) % 60)
        
        return display
    }
}
