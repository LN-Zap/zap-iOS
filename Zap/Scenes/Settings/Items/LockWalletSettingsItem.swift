//
//  Zap
//
//  Created by Otto Suess on 24.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

struct LockWalletSettingsItem: SettingsItem {
    let title = "scene.settings.item.lock_wallet".localized
    
    func didSelectItem(from fromViewController: UIViewController) {
        AuthenticationViewModel.instance.authenticated.value = false
    }
}
