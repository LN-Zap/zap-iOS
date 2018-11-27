//
//  Library
//
//  Created by Otto Suess on 19.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SafariServices

final class HelpSettingsItem: SettingsItem {
    let title = L10n.Scene.Settings.Item.help
    
    func didSelectItem(from fromViewController: UIViewController) {
        guard let url = URL(string: L10n.Link.help) else { return }
        
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.preferredBarTintColor = UIColor.Zap.deepSeaBlue
        safariViewController.preferredControlTintColor = UIColor.Zap.lightningOrange
        fromViewController.present(safariViewController, animated: true)
    }
}
