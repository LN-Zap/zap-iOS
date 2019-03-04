//
//  ZapShared
//
//  Created by Otto Suess on 18.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import Lightning

final class RemoveRemoteNodeSettingsItem: SettingsItem {
    let title = L10n.Scene.Settings.Item.removeRemoteNode

    private weak var disconnectWalletDelegate: DisconnectWalletDelegate?

    init(disconnectWalletDelegate: DisconnectWalletDelegate) {
        self.disconnectWalletDelegate = disconnectWalletDelegate
    }

    func didSelectItem(from fromViewController: UIViewController) {
        disconnectWalletDelegate?.disconnect()
    }
}
