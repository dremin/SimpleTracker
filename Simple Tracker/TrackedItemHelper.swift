//
//  TrackedItemHelper.swift
//  TimeTracker
//
//  Created by Sam Johnson on 12/22/18.
//  Copyright © 2018 Sam Johnson. All rights reserved.
//

import Foundation

class TrackedItemHelper {
    // MARK: Constants
    static let instance = TrackedItemHelper()
    
    // MARK: Properties
    var items: [TrackedItem] = []
    var archiveURL: URL
    
    private init() {
        // get plist url
        do {
            archiveURL = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("SimpleTracker.TrackedItems.plist")
        } catch {
            archiveURL = URL(fileURLWithPath: "~/Library/Application Support/SimpleTracker.TrackedItems.plist")
        }
        
        // load data
        if items.count == 0 {
            load()
        }
    }
    
    // MARK: Functions
    func getTrackedItem(id: Int) -> TrackedItem? {
        for trackedItem in items {
            if trackedItem.id == id {
                return trackedItem
            }
        }
        
        return nil
    }
    
    // MARK: Persistence
    func load() {
        do {
            let data = try Data(contentsOf: archiveURL)
            let decoder = PropertyListDecoder()
            items = try decoder.decode([TrackedItem].self, from: data)
        } catch {
            Logger.log("Error decoding tracked items: %@", error.localizedDescription)
        }
    }
    
    func save() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(items)
            try data.write(to: archiveURL)
        } catch {
            Logger.log("Error encoding tracked items: %@", error.localizedDescription)
        }
    }
}
