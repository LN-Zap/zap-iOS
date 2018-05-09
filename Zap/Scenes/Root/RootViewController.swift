//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

class RootViewController: UIViewController, ContainerViewController {
    // swiftlint:disable:next private_outlet
    @IBOutlet weak var container: UIView?
    
    let viewModel: ViewModel = {
        ViewModel()
//        ViewModel(api: LightningMock(
//            info: Info.template,
//            transactions: [
//                BlockchainTransaction.template,
//                BlockchainTransaction.template
//            ],
//            payments: [
//                Payment.template,
//                Payment.template
//            ]
//        ))
    }()
    
    weak var currentViewController: UIViewController?
    
    private var mainViewController: MainViewController {
        let mainViewController = Storyboard.main.instantiate(viewController: MainViewController.self)
        mainViewController.viewModel = viewModel
        return mainViewController
    }
    
    private var setupViewController: UINavigationController {
        let navigationController = Storyboard.createWallet.initial(viewController: UINavigationController.self)
        if let setupWalletViewController = navigationController.topViewController as? SelectWalletCreationMethodViewController {
            setupWalletViewController.viewModel = viewModel
        }
        return navigationController
    }
    
    private var syncViewController: SyncViewController {
        let syncViewController = Storyboard.sync.initial(viewController: SyncViewController.self)
        syncViewController.viewModel = viewModel
        return syncViewController
    }
    
    private var loadingViewController: LoadingViewController {
        return Storyboard.loading.initial(viewController: LoadingViewController.self)
    }
    
    private var pinViewController: PinViewController {
        let pinViewController = Storyboard.numericKeyPad.initial(viewController: PinViewController.self)
        pinViewController.viewModel = viewModel
        return pinViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInitialViewController(loadingViewController)
        
        NotificationCenter.default.reactive.notification(name: .lndError)
            .observeNext { [weak self] notification in
                guard let message = notification.userInfo?["message"] as? String else { return }
                
                DispatchQueue.main.async {
                    let toast = Toast(message: message, style: .error)
                    UIApplication.topViewController?.presentToast(toast, animated: true, completion: nil)
                }
            }
            .dispose(in: reactive.bag)
        
        viewModel.walletState
            .distinct()
            .observeNext { [weak self] state in
                var viewController: UIViewController?
                
                switch state {
                case .locked:
                    viewController = self?.pinViewController
                case .connecting:
                    viewController = self?.loadingViewController
                case .noInternet:
                    viewController = self?.loadingViewController
                    (viewController as? LoadingViewController)?.message = LndError.noInternet.localizedDescription
                case .noWallet:
                    viewController = self?.setupViewController
                case .syncing:
                    viewController = self?.syncViewController
                case .ready:
                    viewController = self?.mainViewController
                }
                
                if let viewController = viewController {
                    DispatchQueue.main.async {
                        self?.switchToViewController(viewController)
                    }
                }
            }
            .dispose(in: reactive.bag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DebugButton.instance.setup()
    }
}
