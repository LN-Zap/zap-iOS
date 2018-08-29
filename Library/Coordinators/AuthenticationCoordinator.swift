//
//  Library
//
//  Created by Otto Suess on 28.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

/**
 The AuthenticationCoordinator is responsible for displaying the
 `PinViewController` when the wallet is locked and ViewController when a wrong
 pin has been entered a few times.
 It Adds those ViewControllers to a new `UIWindow` above the
 `RootViewController`.
 */
final class AuthenticationCoordinator {
    let authenticationViewModel: AuthenticationViewModel
    private let rootViewController: RootViewController

    private var authenticationWindow: UIWindow?
    private weak var viewController: UIViewController?
    
    private var observation: NSKeyValueObservation?
    
    public init(rootViewController: RootViewController) {
        self.rootViewController = rootViewController
        authenticationViewModel = AuthenticationViewModel()
        
        observation = authenticationViewModel.observe(\.state, options: [.initial]) { _, _ in
            self.updateState()
        }
    }
    
    private func updateState() {
        switch authenticationViewModel.state {
        case .locked:
            presentPin()
        case .timeLocked:
            break // Present Time Lock Screen
        case .unlocked:
            unlock()
        }
    }
    
    private func presentWindow(with viewController: UIViewController) {
        guard self.viewController == nil else { return }
        
        let pinWindow = UIWindow(frame: UIScreen.main.bounds)
        pinWindow.rootViewController = RootViewController()
        pinWindow.windowLevel = UIWindowLevelNormal + 1
        pinWindow.tintColor = UIColor.Zap.lightningOrange
        
        viewController.modalTransitionStyle = .crossDissolve
        pinWindow.makeKeyAndVisible()
        pinWindow.rootViewController?.present(viewController, animated: false, completion: nil)
        
        authenticationWindow = pinWindow
        self.viewController = viewController
    }
    
    private func presentPin() {
        let pinViewController = UIStoryboard.instantiatePinViewController(authenticationViewModel: authenticationViewModel)
        presentWindow(with: pinViewController)
    }
    
    private func unlock() {
        viewController?.dismiss(animated: true) { [weak self] in
            self?.authenticationWindow = nil
        }
    }
}
