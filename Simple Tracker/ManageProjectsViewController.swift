//
//  ManageProjectsViewController.swift
//  TimeTracker
//
//  Created by Sam Johnson on 12/24/18.
//  Copyright © 2018 Sam Johnson. All rights reserved.
//

import Cocoa

class ManageProjectsViewController: NSViewController {
    
    // MARK: Outlets
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var removeButton: NSButton!
    @IBOutlet weak var closeButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    
    // MARK: Properties
    var delegate: MainViewController?
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func selectionchanged() {
        let itemCount = tableView.selectedRowIndexes.count
        
        if itemCount > 0 {
            removeButton.isEnabled = true
        } else {
            removeButton.isEnabled = false
        }
    }
    
    func showAlert(_ title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
    
    // MARK: Button actions
    @IBAction func addButtonPressed(_ sender: NSButton) {
        ProjectHelper.instance.items.append(Project(name: ProjectHelper.instance.generateNewName())!)
        tableView.beginUpdates()
        tableView.insertRows(at: IndexSet(integer: ProjectHelper.instance.items.count - 1), withAnimation: .slideDown)
        tableView.endUpdates()
        tableView.editColumn(0, row: ProjectHelper.instance.items.count - 1, with: nil, select: true)
    }
    
    @IBAction func removeButtonPressed(_ sender: NSButton) {
        for index in tableView.selectedRowIndexes {
            guard let row = tableView.view(atColumn: 0, row: index, makeIfNecessary: false) else {
                continue
            }
            
            let rowId = Int(row.identifier?.rawValue ?? "-1") ?? -1
            
            if rowId >= 0 {
                guard let itemsIndex = ProjectHelper.instance.items.firstIndex(where: { $0 === ProjectHelper.instance.getProject(id: rowId) }) else {
                    continue
                }
                ProjectHelper.instance.items.remove(at: itemsIndex)
            }
        }
        
        tableView.removeRows(at: tableView.selectedRowIndexes, withAnimation: .slideUp)
    }
    
    @IBAction func closeButtonPressed(_ sender: NSButton) {
        // save
        ProjectHelper.instance.save()
        
        // update delegate and dismiss
        delegate?.setupPopUp()
        self.dismiss(sender)
    }
    
    // MARK: Table actions
    @IBAction func cellEdited(_ sender: NSTextField) {
        let rowIndex = tableView.row(for: sender)
        
        guard let row = tableView.view(atColumn: 0, row: rowIndex, makeIfNecessary: false) else {
            return
        }
        let rowId = Int(row.identifier?.rawValue ?? "-1") ?? -1
        
        if rowId >= 0 {
            guard let itemsIndex = ProjectHelper.instance.items.firstIndex(where: { $0 === ProjectHelper.instance.getProject(id: rowId) }) else {
                return
            }
            if !ProjectHelper.instance.items[itemsIndex].setName(sender.stringValue) {
                showAlert("Invalid Project Name", message: "Please enter a valid project name that is unique.")
                // reset table cell text
                (row as! NSTableCellView).textField?.stringValue = ProjectHelper.instance.items[itemsIndex].name
            }
        }
    }
}

// MARK: NSTableViewDataSource
extension ManageProjectsViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return ProjectHelper.instance.items.count
    }
    
}

// MARK: NSTableViewDelegate
extension ManageProjectsViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = ProjectHelper.instance.items[row]
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ProjectEditCell"), owner: nil) as? NSTableCellView {
            // configure the cell
            cell.identifier = NSUserInterfaceItemIdentifier(rawValue: String(item.id))
            cell.textField?.stringValue = item.name
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        selectionchanged()
    }
}
