//
//  Library
//
//  Created by Otto Suess on 19.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SafariServices

final class HelpSettingsItem: SettingsItem {
    let title = "scene.settings.item.help".localized
    
    func didSelectItem(from fromViewController: UIViewController) {
        guard let url = URL(string: "link.help".localized) else { return }
        
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.preferredBarTintColor = UIColor.zap.charcoalGrey
        safariViewController.preferredControlTintColor = UIColor.zap.peach
        fromViewController.present(safariViewController, animated: true)
    }
}
