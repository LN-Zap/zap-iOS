//
//  Library
//
//  Created by 0 on 23.07.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

final class ManageWalletsViewModel {
    var sections = [Section<WalletConfiguration>]()
    let walletConfigurationStore: WalletConfigurationStore

    init(walletConfigurationStore: WalletConfigurationStore) {
        self.walletConfigurationStore = walletConfigurationStore
        updateSections()
    }

    private func updateSections() {
        var localWallets = [WalletConfiguration]()
        var remoteWallets = [WalletConfiguration]()

        for configuration in walletConfigurationStore.configurations {
            switch configuration.connection {
            case .local:
                localWallets.append(configuration)
            case .remote:
                remoteWallets.append(configuration)
            }
        }

        var sections = [Section<WalletConfiguration>]()
        if !localWallets.isEmpty {
            sections.append(Section(title: "Local Wallet", rows: localWallets))
        }
        if !remoteWallets.isEmpty {
            sections.append(Section(title: "Remote Wallets", rows: remoteWallets))
        }

        self.sections = sections
    }

    func removeItem(at indexPath: IndexPath) {
        let item = sections[indexPath.section][indexPath.row]
        walletConfigurationStore.removeConfiguration(item)
        updateSections()
    }
}
