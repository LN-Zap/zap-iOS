//
//  Zap
//
//  Created by Otto Suess on 19.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import UIKit

class GroupedTableViewController: UITableViewController {
    let sections: [Section<SettingsItem>]
    
    init(sections: [Section<SettingsItem>]) {
        self.sections = sections

        super.init(style: .grouped)
        
        tableView.backgroundColor = UIColor.zap.charcoalGrey
        tableView.separatorColor = UIColor.zap.warmGrey
        tableView.rowHeight = 76
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
                detailLabel.font = UIFont.zap.light
                item.subtitle
                    .bind(to: detailLabel.reactive.text)
                    .dispose(in: reactive.bag)
            }
        } else {
            cell = UITableViewCell(style: .default, reuseIdentifier: "DefaultSettingsCell")
        }
        
        cell.textLabel?.text = item.title
        cell.textLabel?.font = UIFont.zap.light
        cell.textLabel?.textColor = .white
        cell.backgroundColor = UIColor.zap.charcoalGreyLight

        if let item = item as? SelectableSettingsItem {
            item.isSelectedOption
                .observeNext {
                    cell.accessoryType = $0 ? .checkmark : .none
                    cell.textLabel?.textColor = $0 ? UIColor.zap.peach : .white
                }
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
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let view = view as? UITableViewHeaderFooterView else { return }
        view.textLabel?.font = UIFont.zap.light
        view.textLabel?.text = sections[section].title
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        guard let view = view as? UITableViewHeaderFooterView else { return }
        view.textLabel?.font = UIFont.zap.light.withSize(13)
        view.textLabel?.textAlignment = .center
    }
}
