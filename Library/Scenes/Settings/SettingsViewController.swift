//
//  Zap
//
//  Created by Otto Suess on 24.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Lightning
import SwiftLnd
import UIKit

private extension Info {
    var isLndVersionOutdated: Bool {
        guard let currentVersion = version else { return false }
        return currentVersion.number < LndConstants.currentVersionNumber
    }
}

final class SettingsViewController: GroupedTableViewController {
    private var info: Info?

    init(info: Info?,
         connection: LightningConnection,
         authenticationViewModel: AuthenticationViewModel,
         pushLndLogViewController: @escaping (UINavigationController) -> Void
    ) {
        self.info = info

        var walletRows: [SettingsItem] = [
            ChangePinSettingsItem(authenticationViewModel: authenticationViewModel)
        ]

        if connection == .local {
            walletRows.append(PushViewControllerSettingsItem(title: L10n.Scene.Settings.Item.lndLog, pushViewController: pushLndLogViewController))
        }

        var sections: [Section<SettingsItem>] = [
            Section(title: L10n.Scene.Settings.title, rows: [
                CurrencySelectionSettingsItem(),
                BitcoinUnitSelectionSettingsItem(),
                OnChainRequestAddressTypeSelectionSettingsItem(),
                BlockExplorerSelectionSettingsItem(),
                LightningRequestExpirySelectionSettingsItem()
            ])
        ]
        sections.append(contentsOf: [
            Section(title: L10n.Scene.Settings.Section.wallet, rows: walletRows)
        ])

        // display outdated lnd version warning
        if info?.isLndVersionOutdated == true, let currentVersion = info?.version {
            sections.insert(Section(title: L10n.Scene.Settings.Section.warning, rows: [
                // swiftlint:disable:next force_unwrapping
                WarningSettingsItem(title: L10n.Scene.Settings.Item.versionWarning(currentVersion.number.description, LndConstants.currentVersionNumber.description), url: URL(string: L10n.Link.lndReleases)!)
            ]), at: 0)
        }
        super.init(sections: sections)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.Scene.Settings.title
        navigationItem.largeTitleDisplayMode = .never
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard
            section == sections.count - 1,
            let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
            else { return nil }

        var versionString = "zap version: \(versionNumber), build: \(buildNumber)"

        if let version = info?.version {
            versionString += "\nlnd version: \(version.number) \(version.commit?.prefix(7) ?? "-")"
        }

        return versionString
    }
}
