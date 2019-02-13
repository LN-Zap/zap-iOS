//
//  Library
//
//  Created by Otto Suess on 04.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class RootTabBarController: UITabBarController {
    private let presentWalletList: (() -> Void)?
    
    override var viewControllers: [UIViewController]? {
        didSet {
            let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
            tabBar.addGestureRecognizer(gestureRecognizer)
        }
    }
    
    init(presentWalletList: @escaping () -> Void) {
        self.presentWalletList = presentWalletList
        
        super.init(nibName: nil, bundle: nil)
        
        tabBar.barTintColor = UIColor.Zap.seaBlue
        tabBar.isTranslucent = false
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        if (recognizer.state == .began),
            let item = tabBar.items?.first,
            let view = item.value(forKey: "view") as? UIView,
            view.frame.contains(recognizer.location(in: tabBar)) {
            presentWalletList?()
        }
    }
}

extension RootTabBarController: HistoryBadgeUpdaterDelegate {
    func updateBadgeValue(_ value: Int) {
        DispatchQueue.main.async {
            self.tabBar.items?[1].badgeValue = value <= 0 ? nil : String(value)
        }
    }
}
