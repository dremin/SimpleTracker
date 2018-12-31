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
    static let NEW_PROJECT_NAME = "New Project"
    
    // MARK: Properties
    static var items: [Project] = []
    
    // MARK: Archiving Paths
    static let ArchiveURL = getUrl()
    
    // MARK: Functions
    public static func initialize() {
        if ProjectHelper.items.count == 0 {
            load()
            
            // if we have nothing after loading, install defaults
            if ProjectHelper.items.count == 0 {
                installDefaults()
            }
        }
    }
    
    static func installDefaults() {
        ProjectHelper.items.append(Project(name: "Sample Project")!)
        save()
    }
    
    static func generateNewName() -> String {
        var newName = NEW_PROJECT_NAME
        var unique = false
        var numTries = 0
        
        while !unique {
            unique = true
            ProjectHelper.items.forEach { project in
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
    
    static func getUrl() -> URL {
        var url: URL
        do {
            url = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("SimpleTracker.Projects.plist")
        } catch {
            url = URL(fileURLWithPath: "~/Library/Application Support/SimpleTracker.Projects.plist")
        }
        
        return url
    }
    
    static func getProject(id: Int) -> Project? {
        for project in ProjectHelper.items {
            if project.id == id {
                return project
            }
        }
        
        return nil
    }
    
    static func getProject(name: String) -> Project? {
        for project in ProjectHelper.items {
            if project.name == name {
                return project
            }
        }
        
        return nil
    }
    
    static func getNames() -> [String] {
        var names: [String] = []
        
        for project in ProjectHelper.items {
            names.append(project.name)
        }
        
        return names
    }
    
    // MARK: Persistence
    static func load() {
        do {
            let data = try Data(contentsOf: ArchiveURL)
            let decoder = PropertyListDecoder()
            ProjectHelper.items = try decoder.decode([Project].self, from: data)
        } catch {
            Logger.log("Error decoding projects: %@", error.localizedDescription)
        }
    }
    
    public static func save() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(ProjectHelper.items)
            try data.write(to: ArchiveURL)
        } catch {
            Logger.log("Error encoding projects: %@", error.localizedDescription)
        }
    }
}
