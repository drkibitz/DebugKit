//
//  DebugOptionsViewController.swift
//  VMApp
//
//  Created by Victor on 2018-08-29.
//  Copyright © 2018 Victor Marcias. All rights reserved.
//
//  --------------------------------------------------------------------------------
//  Use this ViewController to create a new Debugging Tool screen.
//  Customize the debugging options by inheriting from DebugOption.
//  TableView will be automatically arranged with the DebugOptions array.
//  See DebugOption.OptionType for type of Cells you need.
//  Note: custom headers not supported unless overriding UITable methods
//

import UIKit

class DebugOptionsDataSource: DataSource<DebugOption> {

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard isValid(indexPath: indexPath),
            let cell = tableView.dequeueReusableCell(withIdentifier: DebugOptionViewCell.reuseId.rawValue, for: indexPath) as? DebugOptionViewCell else {
            return DebugOptionViewCell()
        }
        cell.option = itemAt(indexPath: indexPath).data
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard isValid(indexPath: indexPath) else { return }

        guard let cell = self.tableView(tableView, cellForRowAt: indexPath) as? DebugOptionViewCell else {
            return
        }

        // toggle cells are handle with the UISwitch event
        guard cell.type != .toggle else { return }

        // *** if its .selectable type, clear previous selection
        if cell.type == .selectable {
            for item in model[indexPath.section].items {
                item.data?.isOn = false
            }
        }

        // toggle and perform action of the cell
        if let option = itemAt(indexPath: indexPath).data {
            option.isOn = !option.isOn
            cell.isOn = option.isOn
            option.action?(option)
        }

        // *** refresh the whole section for .selectable
        if cell.type == .selectable {
            let sectionsToReload = IndexSet(integer: indexPath.section)
            tableView.reloadSections(sectionsToReload, with: .none)
        }
    }
}

class DebugOptionsViewController: DebugTableViewController<DebugOptionsDataSource> {

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(DebugOptionViewCell.self, forCellReuseIdentifier: DebugOptionViewCell.reuseId.rawValue)
    }
}

// MARK: - Debug Option

class DebugOption {

    enum OptionType: Int {
        case text           // informative text
        case disclosure     // continues to another ">"
        case selectable     // unselects the rest "✓"
        case toggle         // toggle independently "( O)" UISwitch
    }

    var type: OptionType = .text
    var title: String? = ""
    var subtitle: String? = ""
    var isOn: Bool = false

    typealias DebugOptionAction = (_ option: DebugOption) -> Void
    var action: DebugOptionAction? // either this or tableView.didSelectRowAt

    convenience init(type: OptionType, title: String = "", subtitle: String = "", action: DebugOptionAction? = nil) {
        self.init()
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }

    // Will Capitalize and space out
    // eg: "myEnumOption" -> "My Enum Option"
    func prettyEnumName(for key: String) -> String {
        var newString: String = ""
        for eachCharacter in key {
            if (eachCharacter >= "A" && eachCharacter <= "Z") == true {
                newString.append(" ")
            }
            newString.append(eachCharacter)
        }
        return newString.capitalized
    }
}

// MARK: - DebugOptionViewCell

private class DebugOptionViewCell: UITableViewCell {

    static let reuseId: DebugTableCellReuseId = "DebugOptionViewCell"

    var option: DebugOption? {
        didSet {
            guard let option = option else {
                return
            }

            textLabel?.numberOfLines = 0
            textLabel?.text = option.title

            detailTextLabel?.numberOfLines = 0
            detailTextLabel?.text = option.subtitle

            type = option.type
            isOn = option.isOn

            accessorySwitchAction = option.action
        }
    }

    var type: DebugOption.OptionType = .text {
        didSet {
            switch type {
            case .text:
                accessoryType = .none
                selectionStyle = .none
            case .disclosure:
                accessoryType = .disclosureIndicator
            case .selectable:
                accessoryType = .checkmark
            case .toggle:
                let toggle = UISwitch()
                toggle.addTarget(self, action: #selector(onSwitchPressed), for: .valueChanged)
                accessoryView = toggle
                selectionStyle = .none
            }
        }
    }

    var isOn: Bool {
        set {
            switch type {
            case .selectable:
                accessoryType = newValue ? .checkmark : .none
            case .toggle:
                accessorySwitch?.isOn = newValue
            default:
                break
            }
        }
        get {
            switch type {
            case .selectable:
                return accessoryType == .checkmark
            case .toggle:
                return accessorySwitch?.isOn ?? false
            default:
                return false
            }
        }
    }

    // MARK: - Toggle Type

    var accessorySwitch: UISwitch? {
        if let toggle = accessoryView as? UISwitch {
            return toggle
        }
        return nil
    }

    var accessorySwitchAction: DebugOption.DebugOptionAction?

    @objc private func onSwitchPressed() {
        if let option = self.option {
            option.isOn = accessorySwitch?.isOn ?? false
            accessorySwitchAction?(option)
        }
    }

    // MARK: -

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
