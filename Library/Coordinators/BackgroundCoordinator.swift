//
//  Library
//
//  Created by Otto Suess on 29.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

/**
 Displays the app's launch screen in a new window on top of everything else when
 the app is sent to the background.
 */
final class BackgroundCoordinator {
    private let rootViewController: RootViewController
    
    private var backgroundWindow: UIWindow?
    private weak var viewController: UIViewController?

    public init(rootViewController: RootViewController) {
        self.rootViewController = rootViewController
    }
    
    func applicationWillEnterForeground() {
        viewController?.dismiss(animated: true) { [weak self] in
            self?.backgroundWindow = nil
        }
    }
    
    func applicationDidEnterBackground() {
        guard self.backgroundWindow == nil else { return }
        
        let backgroundWindow = UIWindow(frame: UIScreen.main.bounds)
        backgroundWindow.rootViewController = RootViewController()
        backgroundWindow.windowLevel = UIWindowLevelAlert + 10
        backgroundWindow.tintColor = UIColor.Zap.lightningOrange
        
        let viewController = Storyboard.background.instantiate(viewController: BackgoundViewController.self)
        viewController.modalTransitionStyle = .crossDissolve
        
        backgroundWindow.makeKeyAndVisible()
        backgroundWindow.rootViewController?.present(viewController, animated: false, completion: nil)
        
        self.backgroundWindow = backgroundWindow
        self.viewController = viewController
    }
}
