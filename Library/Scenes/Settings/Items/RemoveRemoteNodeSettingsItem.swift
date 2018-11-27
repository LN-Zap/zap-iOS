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
    
    private weak var settingsDelegate: SettingsDelegate?
    
    init(settingsDelegate: SettingsDelegate) {
        self.settingsDelegate = settingsDelegate
    }
    
    func didSelectItem(from fromViewController: UIViewController) {
        let alertController = UIAlertController(title: L10n.Scene.Settings.Item.RemoveRemoteNode.Confirmation.title, message: L10n.Scene.Settings.Item.RemoveRemoteNode.Confirmation.message, preferredStyle: .actionSheet)
        
        let cancelAlertAction = UIAlertAction(title: L10n.Generic.cancel, style: .cancel, handler: nil)
        let disconnectAlertAction = UIAlertAction(title: L10n.Scene.Settings.Item.RemoveRemoteNode.Confirmation.button, style: .destructive) { [settingsDelegate] _ in
            settingsDelegate?.disconnect()
        }
        
        alertController.addAction(cancelAlertAction)
        alertController.addAction(disconnectAlertAction)
        
        fromViewController.present(alertController, animated: true)
    }
}
