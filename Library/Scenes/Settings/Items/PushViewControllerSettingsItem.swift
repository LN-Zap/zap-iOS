//
//  Library
//
//  Created by Otto Suess on 09.10.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

final class PushViewControllerSettingsItem: DetailDisclosureSettingsItem {
    private var pushViewController: (UINavigationController) -> Void
    let title: String
    
    init(title: String, pushViewController: @escaping (UINavigationController) -> Void) {
        self.title = title
        self.pushViewController = pushViewController
    }
    
    func didSelectItem(from fromViewController: UIViewController) {
        guard let navigationController = fromViewController.navigationController else { return }
        pushViewController(navigationController)
    }
}
