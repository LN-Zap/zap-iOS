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
    
    var viewModel: ViewModel?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    weak var currentViewController: UIViewController?
    
    private func setChild(_ child: RootChildViewControllers) {
        guard let viewModel = viewModel else { fatalError("viewModel not set") }

        let viewController: UIViewController
        
        switch child {
        case .main:
            viewController = UIStoryboard.instantiateMainViewController(with: viewModel)
        case .setup:
            viewController = UIStoryboard.instantiateSetupViewController(with: viewModel, delegate: self)
        case .sync:
            viewController = UIStoryboard.instantiateSyncViewController(with: viewModel)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch LndConnection.current {
        case .none:
            setChild(.setup)
        default:
            if Environment.skipPinFlow || !AuthenticationViewModel.shared.didSetupPin {
                viewModel = LndConnection.current.viewModel
                if let viewModel = viewModel {
                    setChild(.loading(.none))
                    startWalletUI(with: viewModel)
                }
            } else {
                setChild(.pin)
            }
        }
    }
    
    func startWalletUI(with viewModel: ViewModel) {
        NotificationCenter.default.reactive.notification(name: .lndError)
            .observeNext { notification in
                guard let message = notification.userInfo?["message"] as? String else { return }
                
                DispatchQueue.main.async {
                    let toast = Toast(message: message, style: .error)
                    UIApplication.topViewController?.presentToast(toast, animated: true, completion: nil)
                }
            }
            .dispose(in: reactive.bag)
        
        viewModel.info.walletState
            .distinct()
            .observeNext { [weak self] state in
                switch state {
                case .locked:
                    self?.setChild(.pin)
                case .connecting:
                    self?.setChild(.loading(.none))
                case .noInternet:
                    self?.setChild(.loading(.noInternet))
                case .syncing:
                    self?.setChild(.sync)
                case .ready:
                    self?.setChild(.main)
                }
            }
            .dispose(in: reactive.bag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DebugButton.instance.setup()
    }
    
    private func connect() {
        guard let viewModel = LndConnection.current.viewModel else { return }
        self.viewModel = viewModel
        
        startWalletUI(with: viewModel)
    }
}

extension RootViewController: SetupWalletDelegate {
    func didSetupWallet() {
        if Environment.skipPinFlow || AuthenticationViewModel.shared.didSetupPin {
            connect()
        } else {
            setChild(.setupPin)
        }
    }
}

extension RootViewController: SetupPinDelegate {
    func didSetupPin() {
        connect()
    }
}

extension RootViewController: PinViewDelegate {
    func didAuthenticate() {
        connect()
    }
}
