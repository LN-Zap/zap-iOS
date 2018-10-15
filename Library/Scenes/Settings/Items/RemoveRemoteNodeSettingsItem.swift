//
//  ZapShared
//
//  Created by Otto Suess on 18.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import Lightning
import SwiftLnd

final class RemoveRemoteNodeSettingsItem: SettingsItem {
    let title = "scene.settings.item.remove_remote_node".localized
    
    private weak var settingsDelegate: SettingsDelegate?
    
    init(settingsDelegate: SettingsDelegate) {
        self.settingsDelegate = settingsDelegate
    }
    
    func didSelectItem(from fromViewController: UIViewController) {
        RemoteRPCConfiguration.delete()
        settingsDelegate?.disconnect()
        fromViewController.dismiss(animated: true, completion: nil)
    }
}
