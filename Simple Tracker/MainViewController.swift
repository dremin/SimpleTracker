//
//  ViewController.swift
//  TimeTracker
//
//  Created by Sam Johnson on 12/22/18.
//  Copyright © 2018 Sam Johnson. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {
    // MARK: Outlets
    @IBOutlet weak var addProjectPopUp: NSPopUpButton!
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var addNotesField: NSTextField!
    @IBOutlet weak var itemsTableView: NSTableView!
    @IBOutlet weak var removeItemButton: NSButton!
    @IBOutlet weak var clearAllButton: NSButton!
    
    // MARK: Properties
    var isTracking = false
    var timer: Timer?
    var seconds = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupPopUp()
        addButton.font = NSFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        itemsTableView.delegate = self
        itemsTableView.dataSource = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    func setupPopUp() {
        // clean up
        addProjectPopUp.removeAllItems()
        
        // add projects
        addProjectPopUp.addItems(withTitles: ProjectHelper.getNames())
        
        // add management section
        addProjectPopUp.menu?.addItem(.separator())
        addProjectPopUp.menu?.addItem(NSMenuItem(title: "Manage Projects...", action: #selector(displayManageProjectsSheet(_:)), keyEquivalent: ""))
    }
    
    func secondsString(_ secs: Int) -> String {
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
    
    @objc func displayManageProjectsSheet(_ sender: NSMenuItem) {
        let sheet = self.storyboard?.instantiateController(withIdentifier: "ManageProjectsSheet") as! ManageProjectsViewController
        sheet.delegate = self
        self.presentAsSheet(sheet)
    }
    
    func updateView() {
        setupPopUp()
    }
    
    func selectionchanged() {
        let itemCount = itemsTableView.selectedRowIndexes.count
        
        if itemCount > 0 {
            removeItemButton.isEnabled = true
        } else {
            removeItemButton.isEnabled = false
        }
    }
    
    // MARK: Button actions
    @IBAction func addButtonPressed(_ sender: NSButton) {
        // flip tracking state
        isTracking = !isTracking
        
        if isTracking {
            // now tracking
            addButton.title = secondsString(seconds)
            addButton.image = NSImage(named: "NSTouchBarRecordStopTemplate")
            
            // start timer
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
                self.seconds += 1
                self.addButton.title = self.secondsString(self.seconds)
            }
            
            timer?.fire()
        } else {
            // stop tracking
            timer?.invalidate()
            
            TrackedItemHelper.items.append(TrackedItem(project: ProjectHelper.getProject(name: addProjectPopUp.selectedItem?.title ?? "")?.id ?? 0, notes: addNotesField.stringValue, seconds: seconds))
            
            // reset state
            addButton.title = "Start"
            addButton.image = NSImage(named: "NSTouchBarPlayTemplate")
            addNotesField.stringValue = ""
            seconds = 0
            timer = nil
            
            // save
            TrackedItemHelper.save()
            
            // update table
            itemsTableView.beginUpdates()
            itemsTableView.insertRows(at: IndexSet(integer: TrackedItemHelper.items.count - 1), withAnimation: .slideDown)
            itemsTableView.endUpdates()
        }
    }
    
    @IBAction func clearAllButtonPressed(_ sender: NSButton) {
        TrackedItemHelper.items.removeAll()
        TrackedItemHelper.save()
        
        itemsTableView.reloadData()
    }
    
    @IBAction func removeButtonPressed(_ sender: NSButton) {
        for index in itemsTableView.selectedRowIndexes {
            guard let row = itemsTableView.view(atColumn: 0, row: index, makeIfNecessary: false) else {
                continue
            }
            
            let rowId = Int(row.identifier?.rawValue ?? "-1") ?? -1
            
            if rowId >= 0 {
                guard let itemsIndex = TrackedItemHelper.items.index(where: { $0 === TrackedItemHelper.getTrackedItem(id: rowId) }) else {
                    continue
                }
                TrackedItemHelper.items.remove(at: itemsIndex)
            }
        }
        
        itemsTableView.removeRows(at: itemsTableView.selectedRowIndexes, withAnimation: .slideUp)
        
        TrackedItemHelper.save()
    }
}

// MARK: NSTableViewDataSource
extension MainViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return TrackedItemHelper.items.count
    }
    
}

// MARK: NSTableViewDelegate
extension MainViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = TrackedItemHelper.items[row]
        
        if tableColumn?.identifier.rawValue == "ItemsProjectColumn" {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ItemsProjectCell"), owner: nil) as? NSTableCellView {
                // configure the cell
                cell.identifier = NSUserInterfaceItemIdentifier(rawValue: String(item.id))
                cell.textField?.stringValue = ProjectHelper.getProject(id: item.project)?.name ?? "Unknown"
                cell.textField?.allowsExpansionToolTips = true
                return cell
            }
        } else if tableColumn?.identifier.rawValue == "ItemsHoursColumn" {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ItemsHoursCell"), owner: nil) as? NSTableCellView {
                // configure the cell
                cell.textField?.stringValue = String(format: "%.2f", Double(item.seconds) / 3600.00)
                return cell
            }
        } else if tableColumn?.identifier.rawValue == "ItemsNotesColumn" {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ItemsNotesCell"), owner: nil) as? NSTableCellView {
                // configure the cell
                cell.textField?.stringValue = item.notes
                cell.textField?.allowsExpansionToolTips = true
                return cell
            }
        }
        
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        selectionchanged()
    }
}

