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

final class PinCoordinator {
    private let rootViewController: RootViewController
    private weak var delegate: PinCoordinatorDelegate?
    
    init(rootViewController: RootViewController, delegate: PinCoordinatorDelegate) {
        self.rootViewController = rootViewController
        self.delegate = delegate
    }

    func start() {
        let viewController = UIStoryboard.instantiatePinViewController(didAuthenticate: didAuthenticate)
        self.rootViewController.setContainerContent(viewController)
    }
    
    func didAuthenticate() {
        delegate?.connect()
    }
}
