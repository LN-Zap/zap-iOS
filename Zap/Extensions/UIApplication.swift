//
//  Zap
//
//  Created by Otto Suess on 09.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

extension UIApplication {
    static var topViewController: UIViewController? {
        var topController = UIApplication.shared.keyWindow?.rootViewController
        while let top = topController?.presentedViewController {
            topController = top
        }
        return topController
    }
}
