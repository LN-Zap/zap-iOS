//
//  Zap
//
//  Created by Otto Suess on 24.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

protocol SettingsDelegate: class {
    func disconnect()
}

final class SettingsViewController: GroupedTableViewController {
    static func instantiate(settingsDelegate: SettingsDelegate) -> UINavigationController {
        let viewController = SettingsViewController(settingsDelegate: settingsDelegate)
        
        let navigationController = ZapNavigationController(rootViewController: viewController)
        
        navigationController.tabBarItem.title = "Settings"
        navigationController.tabBarItem.image = UIImage(named: "tabbar_wallet", in: Bundle.library, compatibleWith: nil)
        
        return navigationController
    }
    
    init(settingsDelegate: SettingsDelegate) {
        let sections: [Section<SettingsItem>] = [
            Section(title: "scene.settings.title".localized, rows: [
                CurrencySelectionSettingsItem(),
                BitcoinUnitSelectionSettingsItem(),
                OnChainRequestAddressTypeSelectionSettingsItem()
            ]),
            Section(title: "scene.settings.section.wallet".localized, rows: [
                RemoveRemoteNodeSettingsItem(settingsDelegate: settingsDelegate),
                RemovePinSettingsItem(settingsDelegate: settingsDelegate)
            ]),
            Section(title: nil, rows: [
                HelpSettingsItem(),
                ReportIssueSettingsItem()
            ])
        ]
        
        super.init(sections: sections)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "scene.settings.title".localized

    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard
            section == sections.count - 1,
            let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
            else { return nil }

        return "version: \(versionNumber), build: \(buildNumber)"
    }
}
