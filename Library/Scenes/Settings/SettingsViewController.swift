//
//  Zap
//
//  Created by Otto Suess on 24.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import SwiftLnd
import UIKit

final class SettingsViewController: GroupedTableViewController {
    var info: Info?
    
    static func instantiate(info: Info?, disconnectWalletDelegate: DisconnectWalletDelegate, authenticationViewModel: AuthenticationViewModel, pushChannelList: @escaping (UINavigationController) -> Void, pushNodeURIViewController: @escaping (UINavigationController) -> Void) -> SettingsViewController {
        return SettingsViewController(info: info, disconnectWalletDelegate: disconnectWalletDelegate, authenticationViewModel: authenticationViewModel, pushChannelList: pushChannelList, pushNodeURIViewController: pushNodeURIViewController)
    }
    
    private init(info: Info?, disconnectWalletDelegate: DisconnectWalletDelegate, authenticationViewModel: AuthenticationViewModel, pushChannelList: @escaping (UINavigationController) -> Void, pushNodeURIViewController: @escaping (UINavigationController) -> Void) {
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
                RemoveRemoteNodeSettingsItem(disconnectWalletDelegate: disconnectWalletDelegate),
                ChangePinSettingsItem(authenticationViewModel: authenticationViewModel)
            ]),
            Section(title: nil, rows: [
                // swiftlint:disable:next force_unwrapping
                SafariSettingsItem(title: L10n.Scene.Settings.Item.help, url: URL(string: L10n.Link.help)!),
                // swiftlint:disable:next force_unwrapping
                SafariSettingsItem(title: L10n.Scene.Settings.Item.reportIssue, url: URL(string: "https://github.com/LN-Zap/zap-iOS/issues")!),
                // swiftlint:disable:next force_unwrapping
                SafariSettingsItem(title: L10n.Scene.Settings.Item.privacyPolicy, url: URL(string: "http://zap.jackmallers.com/")!)
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
            let shortHash = components[1]
                .replacingOccurrences(of: "commit=", with: "")
                .components(separatedBy: "-")
                .last?
                .replacingOccurrences(of: "g", with: "")
                .prefix(7) ?? "-"
            versionString += "\nlnd version: \(components[0]) \(shortHash)"
        }
        
        return versionString
    }
}
