//
//  Zap
//
//  Created by Otto Suess on 24.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import SwiftLnd
import UIKit

protocol SettingsDelegate: class {
    var authenticationViewModel: AuthenticationViewModel { get }
    
    func disconnect()
}

final class SettingsViewController: GroupedTableViewController {
    var info: Info?
    
    static func instantiate(info: Info?, settingsDelegate: SettingsDelegate, pushChannelList: @escaping (UINavigationController) -> Void, pushNodeURIViewController: @escaping (UINavigationController) -> Void) -> UINavigationController {
        let viewController = SettingsViewController(info: info, settingsDelegate: settingsDelegate, pushChannelList: pushChannelList, pushNodeURIViewController: pushNodeURIViewController)
        
        let navigationController = ZapNavigationController(rootViewController: viewController)
        
        navigationController.tabBarItem.title = L10n.Scene.Settings.title
        navigationController.tabBarItem.image = UIImage(named: "tabbar_settings", in: Bundle.library, compatibleWith: nil)
        navigationController.view.backgroundColor = UIColor.Zap.background
        
        return navigationController
    }
    
    private init(info: Info?, settingsDelegate: SettingsDelegate, pushChannelList: @escaping (UINavigationController) -> Void, pushNodeURIViewController: @escaping (UINavigationController) -> Void) {
        self.info = info
        
        var lightningRows: [SettingsItem] = [
            ManageChannelsSettingsItem(pushChannelList: pushChannelList)
        ]
        
        if let info = info, !info.uris.isEmpty {
            lightningRows.append(NodeURISettingsItem(pushNodeURIViewController: pushNodeURIViewController))
        }
        
        let sections: [Section<SettingsItem>] = [
            Section(title: L10n.Scene.Settings.title, rows: [
                CurrencySelectionSettingsItem(),
                BitcoinUnitSelectionSettingsItem(),
                OnChainRequestAddressTypeSelectionSettingsItem(),
                BlockExplorerSelectionSettingsItem()
            ]),
            Section(title: "Lightning", rows: lightningRows),
            Section(title: L10n.Scene.Settings.Section.wallet, rows: [
                RemoveRemoteNodeSettingsItem(settingsDelegate: settingsDelegate),
                ChangePinSettingsItem(settingsDelegate: settingsDelegate)
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
        
        title = L10n.Scene.Settings.title
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard
            section == sections.count - 1,
            let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
            else { return nil }

        var versionString = "zap version: \(versionNumber), build: \(buildNumber)"
        
        lndVersion: if let info = info {
            let components = info.version.components(separatedBy: " ")
            guard components.count == 2 else { break lndVersion }
            let shortHash = components[1].replacingOccurrences(of: "commit=", with: "").prefix(7)
            versionString += "\nlnd version: \(components[0]) \(shortHash)"
        }
        
        return versionString
    }
}
