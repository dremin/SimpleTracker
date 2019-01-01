//
//  TrackedItem.swift
//  TimeTracker
//
//  Created by Sam Johnson on 12/22/18.
//  Copyright © 2018 Sam Johnson. All rights reserved.
//

import Foundation

class TrackedItem: Codable {
    var id: Int
    var project: Int
    var notes: String
    var seconds: Int
    
    init(project: Int, notes: String, seconds: Int) {
        self.id = -1
        for i in 0...TrackedItemHelper.instance.items.count {
            // get and use the lowest unused id
            var canUse = true
            TrackedItemHelper.instance.items.forEach { trackedItem in
                if trackedItem.id == i {
                    canUse = false
                }
            }
            
            if canUse {
                self.id = i
                break
            }
        }
        self.project = project
        self.notes = notes
        self.seconds = seconds
    }
}
