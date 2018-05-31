//
//  Zap
//
//  Created by Otto Suess on 31.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class App: NSObject {
    let rootViewController: RootViewController
    var viewModel: ViewModel? {
        didSet {
            rootViewController.viewModel = viewModel
        }
    }
    
    init?(window: UIWindow) {
        guard
            let rootViewController = window.rootViewController as? RootViewController
            else { return nil }
        
        self.rootViewController = rootViewController
        
        super.init()
        
        rootViewController.connect = connect
        
        switch LndConnection.current {
        case .none:
            rootViewController.setChild(.setup)
        default:
            if Environment.skipPinFlow || !AuthenticationViewModel.shared.didSetupPin {

                viewModel = LndConnection.current.viewModel
                rootViewController.viewModel = viewModel
                
                if let viewModel = viewModel {
                    rootViewController.setChild(.loading(.none))
                    startWalletUI(with: viewModel)
                }
            } else {
                rootViewController.setChild(.pin)
            }
        }
    }
    
    private func startWalletUI(with viewModel: ViewModel) {
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
            .skip(first: 1)
            .distinct()
            .observeNext { [weak self] state in
                switch state {
                case .locked:
                    self?.rootViewController.setChild(.pin)
                case .connecting:
                    self?.rootViewController.setChild(.loading(.none))
                case .noInternet:
                    self?.rootViewController.setChild(.loading(.noInternet))
                case .syncing:
                    self?.rootViewController.setChild(.sync)
                case .ready:
                    self?.rootViewController.setChild(.main)
                }
            }
            .dispose(in: reactive.bag)
    }
    
    private func connect() {
        guard let viewModel = LndConnection.current.viewModel else { return }
        self.viewModel = viewModel
        
        startWalletUI(with: viewModel)
    }
}
