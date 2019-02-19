//
//  Zap
//
//  Created by Otto Suess on 02.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

protocol PinSetupCoordinatorDelegate: class {
    func didSetupPin()
}

final class PinSetupCoordinator: Coordinator {
    let rootViewController: RootViewController
    private let authenticationViewModel: AuthenticationViewModel
    private weak var delegate: PinSetupCoordinatorDelegate?

    init(rootViewController: RootViewController, authenticationViewModel: AuthenticationViewModel, delegate: PinSetupCoordinatorDelegate) {
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
        delegate?.didSetupPin()
    }
}
