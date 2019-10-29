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
    }

    @IBAction func addRule(sender: Any) {
        guard let panelController = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("newRulePanel")) as? PanelController else { return }
        panelController.delegate = self
        self.presentAsSheet(panelController)
    }

    @IBAction func removeRule(sender: Any) {
        let selectedIndex = table.selectedRow

    }
}

extension ViewController: PanelControllerDelegate {
    func panelApproved(panel: NSViewController, rule: UserURLRule) {
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
}

protocol PanelControllerDelegate: class {
    func panelApproved(panel: NSViewController, rule: UserURLRule)
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

    @IBAction func approvePanel(sender: Any) {
        guard let matchRuleIndex = radioButtons.firstIndex(where: { $0.state == .on }) else { return }
        let rule = UserURLRule(matchMode: MatchMode.allCases[matchRuleIndex],
                               pattern: patternField.stringValue,
                               appURL: URL(fileURLWithPath: applicationField.stringValue))
        delegate?.panelApproved(panel: self, rule: rule)
    }
}
