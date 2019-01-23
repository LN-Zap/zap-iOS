//
//  Zap
//
//  Created by Otto Suess on 02.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

protocol PinCoordinatorDelegate: class {
    func connect()
}

final class PinSetupCoordinator {
    private let rootViewController: RootViewController
    private let authenticationViewModel: AuthenticationViewModel
    private weak var delegate: PinCoordinatorDelegate?

    init(rootViewController: RootViewController, authenticationViewModel: AuthenticationViewModel, delegate: PinCoordinatorDelegate) {
        self.rootViewController = rootViewController
        self.authenticationViewModel = authenticationViewModel
        self.delegate = delegate
    }
    
    func start() {
        let viewModel = SetupPinViewModel(authenticationViewModel: authenticationViewModel)
        let viewController = SetupPinViewController.instantiate(setupPinViewModel: viewModel, didSetupPin: didSetupPin)
        self.rootViewController.setContainerContent(viewController)
    }
    
    func didSetupPin() {
        delegate?.connect()
    }
}
