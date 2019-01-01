//
//  ProjectHelper.swift
//  TimeTracker
//
//  Created by Sam Johnson on 12/22/18.
//  Copyright © 2018 Sam Johnson. All rights reserved.
//

import Foundation

class ProjectHelper {
    // MARK: Constants
    static let instance = ProjectHelper()
    let NEW_PROJECT_NAME = "New Project"
    
    // MARK: Properties
    var items: [Project] = []
    var archiveURL: URL
    
    private init() {
        // get plist url
        do {
            archiveURL = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("SimpleTracker.Projects.plist")
        } catch {
            archiveURL = URL(fileURLWithPath: "~/Library/Application Support/SimpleTracker.Projects.plist")
        }
        
        // load data
        if items.count == 0 {
            load()
        }
    }
    
    // MARK: Functions
    func installDefaults() {
        items.append(Project(name: "Sample Project")!)
        save()
    }
    
    func generateNewName() -> String {
        var newName = NEW_PROJECT_NAME
        var unique = false
        var numTries = 0
        
        while !unique {
            unique = true
            items.forEach { project in
                if project.name == newName {
                    unique = false
                }
            }
            
            if !unique {
                numTries += 1
                newName = NEW_PROJECT_NAME + " " + String(numTries)
            }
        }
        
        return newName
    }
    
    func getProject(id: Int) -> Project? {
        for project in items {
            if project.id == id {
                return project
            }
        }
        
        return nil
    }
    
    func getProject(name: String) -> Project? {
        for project in items {
            if project.name == name {
                return project
            }
        }
        
        return nil
    }
    
    func getNames() -> [String] {
        var names: [String] = []
        
        for project in items {
            names.append(project.name)
        }
        
        return names
    }
    
    func sort() {
        items = items.sorted(by: { $0.name < $1.name })
    }
    
    // MARK: Persistence
    func load() {
        do {
            let data = try Data(contentsOf: archiveURL)
            let decoder = PropertyListDecoder()
            items = try decoder.decode([Project].self, from: data)
        } catch {
            Logger.log("Error decoding projects: %@", error.localizedDescription)
        }
    }
    
    func save() {
        sort()
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(items)
            try data.write(to: archiveURL)
        } catch {
            Logger.log("Error encoding projects: %@", error.localizedDescription)
        }
    }
}
