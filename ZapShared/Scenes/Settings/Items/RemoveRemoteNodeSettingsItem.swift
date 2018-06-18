//
//  ZapShared
//
//  Created by Otto Suess on 18.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

final class RemoveRemoteNodeSettingsItem: SettingsItem {
    let title = "Remove Remote Node"
    
    func didSelectItem(from fromViewController: UIViewController) {
        RemoteNodeConfiguration.delete()
        fatalError("Crash to restart.")
    }
}
