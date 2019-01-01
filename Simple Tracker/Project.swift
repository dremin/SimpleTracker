//
//  Project.swift
//  TimeTracker
//
//  Created by Sam Johnson on 12/22/18.
//  Copyright © 2018 Sam Johnson. All rights reserved.
//

import Foundation

class Project: Codable {
    var id: Int
    var name: String
    
    init?(name: String) {
        self.id = -1
        for i in 0...ProjectHelper.instance.items.count {
            // get and use the lowest unused id
            var canUse = true
            ProjectHelper.instance.items.forEach { project in
                if project.id == i {
                    canUse = false
                }
            }
            
            if canUse {
                self.id = i
                break
            }
        }
        
        self.name = ""
        
        if !setName(name) {
            return nil
        }
    }
    
    func setName(_ newName: String) -> Bool {
        guard newName != "" else {
            Logger.log("Empty project name provided")
            return false
        }
        
        var unique = true
        ProjectHelper.instance.items.forEach { project in
            if project.name == newName && project.id != self.id {
                unique = false
            }
        }
        
        guard unique else {
            Logger.log("Non-unique project name provided %@", newName)
            return false
        }
        
        self.name = newName
        return true
    }
}
