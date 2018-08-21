//
//  Zap
//
//  Created by Otto Suess on 21.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class StatusBarDelegatingNavigationController: UINavigationController {
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return viewControllers.first
    }
}
