//
//  Settings.swift
//  Simple Tracker
//
//  Created by Sam Johnson on 2/18/19.
//  Copyright © 2019 Sam Johnson. All rights reserved.
//

import Foundation

class SettingsHelper {
    // MARK: Constants
    static let instance = SettingsHelper()
    
    // MARK: Properties
    var currentSettings = Settings(sortOrder: TrackedItemHelper.sortOrder.project, sortAsc: true) // defaults
    var archiveURL: URL
    var loaded = false
    
    struct Settings: Codable {
        var sortOrder: TrackedItemHelper.sortOrder
        var sortAsc: Bool
    }
    
    private init() {
        // get plist url
        do {
            archiveURL = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("SimpleTracker.Settings.plist")
        } catch {
            archiveURL = URL(fileURLWithPath: "~/Library/Application Support/SimpleTracker.Settings.plist")
        }
        
        // load data
        if !loaded {
            load()
        }
    }
    
    // MARK: Persistence
    func load() {
        do {
            let data = try Data(contentsOf: archiveURL)
            let decoder = PropertyListDecoder()
            currentSettings = try decoder.decode(Settings.self, from: data)
            loaded = true
        } catch {
            Logger.log("Error decoding settings: %@", error.localizedDescription)
        }
    }
    
    func save() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(currentSettings)
            try data.write(to: archiveURL)
        } catch {
            Logger.log("Error encoding settings: %@", error.localizedDescription)
        }
    }
}
