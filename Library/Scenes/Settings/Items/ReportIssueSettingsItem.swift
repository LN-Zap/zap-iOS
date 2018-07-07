//
//  Library
//
//  Created by Otto Suess on 07.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SafariServices

final class ReportIssueSettingsItem: SettingsItem {
    let title = "scene.settings.item.report_issue".localized
    
    func didSelectItem(from fromViewController: UIViewController) {
        guard let url = URL(string: "https://github.com/LN-Zap/zap-iOS/issues") else { return }
        
        UIApplication.shared.open(url)
    }
}
