//
//  Library
//
//  Created by Otto Suess on 05.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SafariServices

final class SafariSettingsItem: SettingsItem {
    let title: String
    let url: URL
    
    init(title: String, url: URL) {
        self.title = title
        self.url = url
    }
    
    func didSelectItem(from fromViewController: UIViewController) {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.preferredBarTintColor = UIColor.Zap.deepSeaBlue
        safariViewController.preferredControlTintColor = UIColor.Zap.lightningOrange
        fromViewController.present(safariViewController, animated: true)
    }
}
