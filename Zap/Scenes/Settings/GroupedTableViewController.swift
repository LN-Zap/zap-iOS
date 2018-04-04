//
//  Zap
//
//  Created by Otto Suess on 19.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import UIKit

class GroupedTableViewController: UITableViewController {
    private let sections: [Section<SettingsItem>]
    
    init(sections: [Section<SettingsItem>]) {
        self.sections = sections

        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = sections[indexPath.section][indexPath.row]
        
        let cell: UITableViewCell
        if let item = item as? SubtitleSettingsItem {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "Value1SettingsCell")
            if let detailLabel = cell.detailTextLabel {
                detailLabel.font = Font.light
                item.subtitle
                    .bind(to: detailLabel.reactive.text)
                    .dispose(in: reactive.bag)
            }
        } else {
            cell = UITableViewCell(style: .default, reuseIdentifier: "DefaultSettingsCell")
        }
        
        cell.textLabel?.text = item.title
        cell.textLabel?.font = Font.light
        
        if let item = item as? SelectableSettingsItem {
            item.isSelectedOption
                .observeNext { cell.accessoryType = $0 ? .checkmark : .none }
                .dispose(in: reactive.bag)
        } else if item is DetailDisclosureSettingsItem {
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sections[indexPath.section][indexPath.row].didSelectItem(from: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
