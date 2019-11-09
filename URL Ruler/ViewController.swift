//
//  ViewController.swift
//  URL Ruler
//
//  Created by Finn Gaida on 29.10.19.
//  Copyright © 2019 Finn Gaida. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet var table: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        table.registerForDraggedTypes([.string])
    }

    @IBAction func addRule(sender: Any) {
        guard let panelController = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("newRulePanel")) as? PanelController else { return }
        panelController.delegate = self
        self.presentAsSheet(panelController)
    }

    @IBAction func removeRule(sender: Any) {
        let selectedIndex = table.selectedRow
        Routing.shared.rules.remove(at: selectedIndex)
        self.table.reloadData()
    }
}

extension ViewController: PanelControllerDelegate {
    func panelApproved(panel: NSViewController, rule: URLRule) {
        Routing.shared.rules.append(rule)
        table.reloadData()
        dismiss(panel)
    }
}

extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return Routing.shared.rules.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard
            let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("cell"), owner: nil) as? NSTableCellView,
            let column = tableColumn
        else { return nil }

        let rule = Routing.shared.rules[row]

        switch column.identifier.rawValue {
        case "matchingRuleColumn":
            view.textField?.stringValue = rule.pattern

        case "applicationColumn":
            view.textField?.stringValue = rule.appURL.lastPathComponent

        default: return nil
        }

        return view
    }

    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let item = NSPasteboardItem()
        item.setString("\(Routing.shared.rules[row].hashValue)", forType: .string)
        return item
    }

    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        switch dropOperation {
        case .above: return .move
        case .on: return []
        @unknown default:
            fatalError()
        }
    }

    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        guard
            let item = info.draggingPasteboard.pasteboardItems?.first,
            let theString = item.string(forType: .string),
            let hash = Int(theString),
            let rule = Routing.shared.rules.first(where: { $0.hashValue == hash }),
            let originalRow = Routing.shared.rules.firstIndex(of: rule)
        else { return false }

        var newRow = row
        // When you drag an item downwards, the "new row" index is actually --1. Remember dragging operation is `.above`.
        if originalRow < newRow {
            newRow = row - 1
        }

        tableView.beginUpdates()
        tableView.moveRow(at: originalRow, to: newRow)
        tableView.endUpdates()

        return true
    }
}

protocol PanelControllerDelegate: class {
    func panelApproved(panel: NSViewController, rule: URLRule)
}

class PanelController: NSViewController {
    @IBOutlet var regexRadioButton: NSButton!
    @IBOutlet var beginsWithRadioButton: NSButton!
    @IBOutlet var containsRadioButton: NSButton!

    var radioButtons: [NSButton] {
        return [regexRadioButton, beginsWithRadioButton, containsRadioButton]
    }

    @IBOutlet var patternField: NSTextField!
    @IBOutlet var applicationField: NSTextField!

    weak var delegate: PanelControllerDelegate?

    @IBAction func radioClicked(sender: NSButton) {
        for button in radioButtons {
            if button != sender { button.state = .off }
        }
    }

    @IBAction func openClicked(sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.directoryURL = URL(fileURLWithPath: "~/Applications")
        openPanel.begin { [unowned self] response in
            switch response {
            case .OK:
                guard let url = openPanel.url else { return }
                self.applicationField.stringValue = url.path

            default: break
            }
        }
    }

    @IBAction func approvePanel(sender: Any) {
        guard let matchRuleIndex = radioButtons.firstIndex(where: { $0.state == .on }) else { return }
        let rule = URLRule(matchMode: MatchMode.allCases[matchRuleIndex],
                               pattern: patternField.stringValue,
                               appURL: URL(fileURLWithPath: applicationField.stringValue))
        delegate?.panelApproved(panel: self, rule: rule)
    }
}
