//
//  Library
//
//  Created by Otto Suess on 25.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class ZapNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.prefersLargeTitles = true
        navigationBar.barTintColor = UIColor.zap.backgroundGradientTop
        navigationBar.isTranslucent = false
    }
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return viewControllers.first
    }
}
