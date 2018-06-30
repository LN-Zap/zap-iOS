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
    
    func didSelectItem(from fromViewController: UIViewController) {
        RemoteRPCConfiguration.delete()
        fatalError("Crash to restart.")
    }
}
