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
    
    // MARK: Constants
    let MANAGE_PROJECTS = "Manage Projects..."
    
    // MARK: Properties
    var lastSelectedProject: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupPopUp()
        updateButton()
        
        addButton.font = NSFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        itemsTableView.delegate = self
        itemsTableView.dataSource = self
        Tracker.instance.delegate = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @objc func displayManageProjectsSheet(_ sender: NSMenuItem) {
        let sheet = self.storyboard?.instantiateController(withIdentifier: "ManageProjectsSheet") as! ManageProjectsViewController
        sheet.delegate = self
        self.presentAsSheet(sheet)
    }
    
    // MARK: UI update functions
    func setupPopUp() {
        // clean up
        addProjectPopUp.removeAllItems()
        
        // add projects
        addProjectPopUp.addItems(withTitles: ProjectHelper.instance.getNames())
        
        // add management section
        addProjectPopUp.menu?.addItem(.separator())
        addProjectPopUp.menu?.addItem(NSMenuItem(title: MANAGE_PROJECTS, action: #selector(displayManageProjectsSheet(_:)), keyEquivalent: ""))
        
        if let lastSelected = lastSelectedProject {
            if addProjectPopUp.item(withTitle: lastSelected) != nil {
                addProjectPopUp.selectItem(withTitle: lastSelected)
            }
        }
    }
    
    func selectionchanged() {
        let itemCount = itemsTableView.selectedRowIndexes.count
        
        if itemCount > 0 {
            removeItemButton.isEnabled = true
        } else {
            removeItemButton.isEnabled = false
        }
    }
    
    func updateButton() {
        if Tracker.instance.isTracking {
            addButton.title = Tracker.instance.secondsString()
            addButton.image = NSImage(named: "NSTouchBarRecordStopTemplate")
        } else {
            addButton.title = "Start"
            addButton.image = NSImage(named: "NSTouchBarPlayTemplate")
        }
    }
    
    func updateTable() {
        itemsTableView.beginUpdates()
        itemsTableView.insertRows(at: IndexSet(integer: TrackedItemHelper.instance.items.count - 1), withAnimation: .slideDown)
        itemsTableView.endUpdates()
    }
    
    func clearNotes() {
        addNotesField.stringValue = ""
    }
    
    // MARK: Button actions
    @IBAction func addButtonPressed(_ sender: NSButton) {
        if Tracker.instance.isTracking {
            // stop tracking
            Tracker.instance.stopTracking(project: addProjectPopUp.selectedItem?.title ?? "", notes: addNotesField.stringValue)
        } else {
            // start tracking
            Tracker.instance.startTracking()
        }
    }
    
    @IBAction func clearAllButtonPressed(_ sender: NSButton) {
        TrackedItemHelper.instance.items.removeAll()
        TrackedItemHelper.instance.save()
        
        itemsTableView.reloadData()
    }
    
    @IBAction func removeButtonPressed(_ sender: NSButton) {
        for index in itemsTableView.selectedRowIndexes {
            guard let row = itemsTableView.view(atColumn: 0, row: index, makeIfNecessary: false) else {
                continue
            }
            
            let rowId = Int(row.identifier?.rawValue ?? "-1") ?? -1
            
            if rowId >= 0 {
                guard let itemsIndex = TrackedItemHelper.instance.items.index(where: { $0 === TrackedItemHelper.instance.getTrackedItem(id: rowId) }) else {
                    continue
                }
                TrackedItemHelper.instance.items.remove(at: itemsIndex)
            }
        }
        
        itemsTableView.removeRows(at: itemsTableView.selectedRowIndexes, withAnimation: .slideUp)
        
        TrackedItemHelper.instance.save()
    }
    
    // MARK: PopUp actions
    @IBAction func projectSelected(_ sender: NSPopUpButton) {
        if sender.selectedItem?.title != MANAGE_PROJECTS {
            lastSelectedProject = sender.selectedItem?.title
        }
    }
}

// MARK: NSTableViewDataSource
extension MainViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return TrackedItemHelper.instance.items.count
    }
    
}

// MARK: NSTableViewDelegate
extension MainViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = TrackedItemHelper.instance.items[row]
        
        if tableColumn?.identifier.rawValue == "ItemsProjectColumn" {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ItemsProjectCell"), owner: nil) as? NSTableCellView {
                // configure the cell
                cell.identifier = NSUserInterfaceItemIdentifier(rawValue: String(item.id))
                cell.textField?.stringValue = ProjectHelper.instance.getProject(id: item.project)?.name ?? "Unknown"
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

