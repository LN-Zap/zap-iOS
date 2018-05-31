//
//  Zap
//
//  Created by Otto Suess on 31.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static func instantiateMainViewController(with viewModel: ViewModel) -> MainViewController {
        let mainViewController = Storyboard.main.instantiate(viewController: MainViewController.self)
        mainViewController.viewModel = viewModel
        return mainViewController
    }
    
    static func instantiateSetupViewController(with delegate: SetupWalletDelegate) -> UINavigationController {
        let navigationController = Storyboard.createWallet.initial(viewController: UINavigationController.self)
        if let setupWalletViewController = navigationController.topViewController as? SelectWalletCreationMethodViewController {
            setupWalletViewController.delegate = delegate
        }
        return navigationController
    }
    
    static func instantiateSyncViewController(with viewModel: ViewModel) -> SyncViewController {
        let syncViewController = Storyboard.sync.initial(viewController: SyncViewController.self)
        syncViewController.viewModel = viewModel
        return syncViewController
    }
    
    static func instantiateLoadingViewController(with: LoadingViewController.Message) -> LoadingViewController {
        return Storyboard.loading.initial(viewController: LoadingViewController.self)
    }
    
    static func instantiatePinViewController(with delegate: PinViewDelegate) -> PinViewController {
        let pinViewController = Storyboard.numericKeyPad.initial(viewController: PinViewController.self)
        pinViewController.delegate = delegate
        return pinViewController
    }
    
    static func instantiateSetupPinViewController(with delegate: SetupPinDelegate) -> SetupPinViewController {
        let setupPinViewController = Storyboard.numericKeyPad.instantiate(viewController: SetupPinViewController.self)
        setupPinViewController.delegate = delegate
        return setupPinViewController
    }
}
