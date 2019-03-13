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
final class AuthenticationCoordinator: Coordinator {
    let authenticationViewModel: AuthenticationViewModel
    let rootViewController: RootViewController

    private var authenticationWindow: UIWindow?
    private weak var viewController: UIViewController?

    private var observation: NSKeyValueObservation?

    public init(rootViewController: RootViewController) {
        self.rootViewController = rootViewController
        authenticationViewModel = AuthenticationViewModel()
    }

    func start() {
        observation = authenticationViewModel.observe(\.state, options: [.initial]) { _, _ in
            self.updateState()
        }
    }

    private func updateState() {
        switch authenticationViewModel.state {
        case .locked:
            presentPin()
        case .timeLocked:
            presentTimeLock()
        case .unlocked:
            unlock()
        }
    }

    private func presentWindow(with viewController: UIViewController) {
        guard self.viewController == nil || type(of: self.viewController) != type(of: viewController) else { return }

        if self.authenticationWindow == nil {
            let authenticationWindow = UIWindow(frame: UIScreen.main.bounds)
            authenticationWindow.windowLevel = WindowLevel.authentication
            authenticationWindow.tintColor = UIColor.Zap.lightningOrange
            authenticationWindow.makeKeyAndVisible()
            self.authenticationWindow = authenticationWindow
        }

        viewController.modalTransitionStyle = .crossDissolve
        authenticationWindow?.rootViewController = viewController

        self.viewController = viewController
    }

    private func presentPin() {
        let pinViewController = PinViewController.instantiate(authenticationViewModel: authenticationViewModel)
        presentWindow(with: pinViewController)
    }

    private func presentTimeLock() {
        let timeLockedViewController = TimeLockedViewController.instantiate(authenticationViewModel: authenticationViewModel)
        presentWindow(with: timeLockedViewController)
    }

    private func unlock() {
        UIView.animate(withDuration: 0.25, animations: {
            self.viewController?.view.alpha = 0
        }, completion: { _ in
            self.authenticationWindow?.rootViewController = nil
            self.authenticationWindow = nil
        })
    }

    func applicationDidBecomeActive() {
        authenticationViewModel.updateStateAfterAppRestart()
    }
}
