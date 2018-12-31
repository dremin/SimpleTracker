//
//  TrackedItemHelper.swift
//  TimeTracker
//
//  Created by Sam Johnson on 12/22/18.
//  Copyright © 2018 Sam Johnson. All rights reserved.
//

import Foundation

class TrackedItemHelper {
    static var items: [TrackedItem] = []
    
    // MARK: Archiving Paths
    static let ArchiveURL = getUrl()
    
    // MARK: Functions
    public static func initialize() {
        if TrackedItemHelper.items.count == 0 {
            load()
        }
    }
    
    public static func reload() {
        load()
    }
    
    static func getUrl() -> URL {
        var url: URL
        do {
            url = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("SimpleTracker.TrackedItems.plist")
        } catch {
            url = URL(fileURLWithPath: "~/Library/Application Support/SimpleTracker.TrackedItems.plist")
        }
        
        return url
    }
    
    static func getTrackedItem(id: Int) -> TrackedItem? {
        for trackedItem in TrackedItemHelper.items {
            if trackedItem.id == id {
                return trackedItem
            }
        }
        
        return nil
    }
    
    // MARK: Persistence
    static func load() {
        do {
            let data = try Data(contentsOf: ArchiveURL)
            let decoder = PropertyListDecoder()
            TrackedItemHelper.items = try decoder.decode([TrackedItem].self, from: data)
        } catch {
            Logger.log("Error decoding tracked items: %@", error.localizedDescription)
        }
    }
    
    public static func save() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(TrackedItemHelper.items)
            try data.write(to: ArchiveURL)
        } catch {
            Logger.log("Error encoding tracked items: %@", error.localizedDescription)
        }
    }
}
