//
//  Zap
//
//  Created by Otto Suess on 02.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class PinSetupCoordinator {
    private let rootViewController: RootViewController
    private weak var delegate: PinCoordinatorDelegate?

    init(rootViewController: RootViewController, delegate: PinCoordinatorDelegate) {
        self.rootViewController = rootViewController
        self.delegate = delegate
    }
    
    func start() {
        let viewController = UIStoryboard.instantiateSetupPinViewController(didSetupPin: didSetupPin)
        self.rootViewController.setContainerContent(viewController)
    }
    
    func didSetupPin() {
        delegate?.connect()
    }
}
