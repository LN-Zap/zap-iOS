//
//  ZapShared
//
//  Created by Otto Suess on 18.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import Lightning

final class RemovePinSettingsItem: SettingsItem {
    let title = "scene.settings.item.reset_pin".localized
    
    private weak var settingsDelegate: SettingsDelegate?
    
    init(settingsDelegate: SettingsDelegate) {
        self.settingsDelegate = settingsDelegate
    }
    
    func didSelectItem(from fromViewController: UIViewController) {
        AuthenticationViewModel.resetPin()
        settingsDelegate?.disconnect()
        fromViewController.dismiss(animated: true, completion: nil)
    }
}
