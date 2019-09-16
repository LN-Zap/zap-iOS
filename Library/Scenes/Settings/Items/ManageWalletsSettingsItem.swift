//
//  ZapShared
//
//  Created by Otto Suess on 18.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning
import ReactiveKit

final class ManageWalletsSettingsItem: SettingsItem, SubtitleSettingsItem {
    let subtitle: Signal<String?, Never>

    let title = L10n.Scene.Settings.Item.removeRemoteNode

    private weak var disconnectWalletDelegate: DisconnectWalletDelegate?

    init(disconnectWalletDelegate: DisconnectWalletDelegate) {
        self.disconnectWalletDelegate = disconnectWalletDelegate

        let alias = WalletConfigurationStore.load().selectedWallet?.alias
        subtitle = Observable(alias).toSignal()
    }

    func didSelectItem(from fromViewController: UIViewController) {
        disconnectWalletDelegate?.disconnect()
    }
}
