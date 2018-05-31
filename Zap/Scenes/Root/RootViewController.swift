//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

enum RootChildViewControllers {
    case main
    case setup
    case sync
    case loading(LoadingViewController.Message)
    case setupPin
    case pin
}

class RootViewController: UIViewController, ContainerViewController {
    // swiftlint:disable:next private_outlet
    @IBOutlet weak var container: UIView?
    weak var currentViewController: UIViewController?
    
    var viewModel: ViewModel?
    var connect: (() -> Void)?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setChild(_ child: RootChildViewControllers) {

        let viewController: UIViewController
        
        switch child {
        case .main:
            guard let viewModel = viewModel else { fatalError("viewModel not set") }
            viewController = UIStoryboard.instantiateMainViewController(with: viewModel)
        case .sync:
            guard let viewModel = viewModel else { fatalError("viewModel not set") }
            viewController = UIStoryboard.instantiateSyncViewController(with: viewModel)
        case .setup:
            viewController = UIStoryboard.instantiateSetupViewController(with: self)
        case .loading(let message):
            viewController = UIStoryboard.instantiateLoadingViewController(with: message)
        case .pin:
            viewController = UIStoryboard.instantiatePinViewController(with: self)
        case .setupPin:
            viewController = UIStoryboard.instantiateSetupPinViewController(with: self)
        }
        
        DispatchQueue.main.async {
            self.setContainerContent(viewController)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DebugButton.instance.setup()
    }
}

extension RootViewController: SetupWalletDelegate {
    func didSetupWallet() {
        if Environment.skipPinFlow || AuthenticationViewModel.shared.didSetupPin {
            connect?()
        } else {
            setChild(.setupPin)
        }
    }
}

extension RootViewController: SetupPinDelegate {
    func didSetupPin() {
        connect?()
    }
}

extension RootViewController: PinViewDelegate {
    func didAuthenticate() {
        connect?()
    }
}
