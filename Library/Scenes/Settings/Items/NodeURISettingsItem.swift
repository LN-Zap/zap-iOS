//
//  Library
//
//  Created by Otto Suess on 18.10.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

final class NodeURISettingsItem: DetailDisclosureSettingsItem {
    private var pushNodeURIViewController: (UINavigationController) -> Void
    
    var title = "scene.settings.item.node_uri".localized
    
    init(pushNodeURIViewController: @escaping (UINavigationController) -> Void) {
        self.pushNodeURIViewController = pushNodeURIViewController
    }
    
    func didSelectItem(from fromViewController: UIViewController) {
        guard let navigationController = fromViewController.navigationController else { return }
        pushNodeURIViewController(navigationController)
    }
}
