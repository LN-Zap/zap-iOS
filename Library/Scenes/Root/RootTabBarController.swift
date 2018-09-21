//
//  Library
//
//  Created by Otto Suess on 04.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class RootTabBarController: UITabBarController {

    init() {
        super.init(nibName: nil, bundle: nil)
        
        tabBar.barTintColor = UIColor.Zap.seaBlue
        tabBar.isTranslucent = false
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RootTabBarController: HistoryBadgeUpdaterDelegate {
    func updateBadgeCount(_ value: Int) {
        DispatchQueue.main.async {
            self.tabBar.items?[1].badgeValue = value <= 0 ? nil : String(value)
        }
    }
}
