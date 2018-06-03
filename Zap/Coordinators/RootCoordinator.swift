//
//  Zap
//
//  Created by Otto Suess on 31.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class RootCoordinator: NSObject, SetupCoordinatorDelegate, PinCoordinatorDelegate {
    private let rootViewController: RootViewController
    private var viewModel: ViewModel?
    
    private var currentCoordinator: Any?
    private var route: Route?
    
    init?(window: UIWindow) {
        guard
            let rootViewController = window.rootViewController as? RootViewController
            else { return nil }
        
        self.rootViewController = rootViewController
    }
    
    func start() {
        switch LndConnection.current {
        case .none:
            presentSetup()
        default:
            if Environment.skipPinFlow || !AuthenticationViewModel.shared.didSetupPin {
                
                viewModel = LndConnection.current.viewModel
                
                if let viewModel = viewModel {
                    presentLoading(message: .none)
                    startWalletUI(with: viewModel)
                }
            } else {
                presentPin()
            }
        }
    }
    
    func handle(_ route: Route?) {
        self.route = route
        
        if let route = route {
            switch route {
            case .send(let invoice):
                if let mainCoordinator = currentCoordinator as? MainCoordinator {
                    mainCoordinator.presentSend(invoice: invoice)
                    self.route = nil
                }
            case .request:
                if let mainCoordinator = currentCoordinator as? MainCoordinator {
                    mainCoordinator.presentRequest()
                    self.route = nil
                }
            }
        }
    }
    
    private func presentMain() {
        guard let viewModel = viewModel else { return }
        let mainCoordinator = MainCoordinator(rootViewController: rootViewController, viewModel: viewModel)
        currentCoordinator = mainCoordinator
        mainCoordinator.start()
                
        if let route = self.route {
            handle(route)
        }
    }
    
    private func presentSetup() {
        let setupCoordinator = SetupCoordinator(rootViewController: rootViewController, delegate: self)
        currentCoordinator = setupCoordinator
        setupCoordinator.start()
    }
    
    private func presentSync() {
        guard let viewModel = viewModel else { fatalError("viewModel not set") }
        let viewController = UIStoryboard.instantiateSyncViewController(with: viewModel)
        presentViewController(viewController)
    }
    
    private func presentLoading(message: LoadingViewController.Message) {
        let viewController = UIStoryboard.instantiateLoadingViewController(message: message)
        presentViewController(viewController)
    }
    
    private func presentPin() {
        let pinCoordinator = PinCoordinator(rootViewController: rootViewController, delegate: self)
        currentCoordinator = pinCoordinator
        pinCoordinator.start()
    }
    
    internal func presentSetupPin() {
        let pinSetupCoordinator = PinSetupCoordinator(rootViewController: rootViewController, delegate: self)
        currentCoordinator = pinSetupCoordinator
        pinSetupCoordinator.start()
    }
    
    private func presentViewController(_ viewController: UIViewController) {
        DispatchQueue.main.async {
            self.rootViewController.setContainerContent(viewController)
        }
    }
    
    private func startWalletUI(with viewModel: ViewModel) {
        startListeningForErrorNotifications()
        
        viewModel.info.walletState
            .skip(first: 1)
            .distinct()
            .observeNext { [weak self] state in
                switch state {
                case .locked:
                    self?.presentPin()
                case .connecting:
                    if case .remote = LndConnection.current {
                        viewModel.stop()
                        self?.viewModel = nil
                        print("stop viewModel")
                        self?.presentSetup()
                    } else {
                        self?.presentLoading(message: .none)
                    }
                case .noInternet:
                    self?.presentLoading(message: .noInternet)
                case .syncing:
                    self?.presentSync()
                case .ready:
                    self?.presentMain()
                }
            }
            .dispose(in: reactive.bag)
    }
    
    private func startListeningForErrorNotifications() { // TODO: replace this with something better
        NotificationCenter.default.reactive.notification(name: .lndError)
            .observeNext { notification in
                guard let message = notification.userInfo?["message"] as? String else { return }
                
                DispatchQueue.main.async {
                    let toast = Toast(message: message, style: .error)
                    UIApplication.topViewController?.presentToast(toast, animated: true, completion: nil)
                }
            }
            .dispose(in: reactive.bag)
    }
    
    internal func connect() {
        DispatchQueue.main.async {
            guard let viewModel = LndConnection.current.viewModel else { return }
            self.viewModel = viewModel
            self.startWalletUI(with: viewModel)
        }
    }
}
