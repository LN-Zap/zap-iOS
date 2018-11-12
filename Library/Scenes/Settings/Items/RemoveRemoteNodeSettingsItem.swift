//
//  ZapShared
//
//  Created by Otto Suess on 18.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import Lightning

final class RemoveRemoteNodeSettingsItem: SettingsItem {
    let title = "scene.settings.item.remove_remote_node".localized
    
    private weak var settingsDelegate: SettingsDelegate?
    
    init(settingsDelegate: SettingsDelegate) {
        self.settingsDelegate = settingsDelegate
    }
    
    func didSelectItem(from fromViewController: UIViewController) {
        let alertController = UIAlertController(title: "scene.settings.item.remove_remote_node.confirmation.title".localized, message: "scene.settings.item.remove_remote_node.confirmation.message".localized, preferredStyle: .actionSheet)
        
        let cancelAlertAction = UIAlertAction(title: "generic.cancel".localized, style: .cancel, handler: nil)
        let disconnectAlertAction = UIAlertAction(title: "scene.settings.item.remove_remote_node.confirmation.button".localized, style: .destructive) { [settingsDelegate] _ in
            settingsDelegate?.disconnect()
        }
        
        alertController.addAction(cancelAlertAction)
        alertController.addAction(disconnectAlertAction)
        
        fromViewController.present(alertController, animated: true)
    }
}
