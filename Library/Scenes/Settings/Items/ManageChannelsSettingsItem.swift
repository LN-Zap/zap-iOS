//
//  Library
//
//  Created by Otto Suess on 09.10.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

final class ManageChannelsSettingsItem: DetailDisclosureSettingsItem {
    private var pushChannelList: (UINavigationController) -> Void

    var title = "scene.settings.item.manage_channels".localized
    
    init(pushChannelList: @escaping (UINavigationController) -> Void) {
        self.pushChannelList = pushChannelList
    }
    
    func didSelectItem(from fromViewController: UIViewController) {
        guard let navigationController = fromViewController.navigationController else { return }
        pushChannelList(navigationController)
    }
}
