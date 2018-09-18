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
        navigationBar.barTintColor = UIColor.Zap.seaBlueGradient
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage()
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return viewControllers.first
    }
}
