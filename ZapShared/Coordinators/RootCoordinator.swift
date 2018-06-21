//
//  Zap
//
//  Created by Otto Suess on 31.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

public final class RootCoordinator: NSObject, SetupCoordinatorDelegate, PinCoordinatorDelegate {
    private let rootViewController: RootViewController
    private var lightningService: LightningService?
    
    private var currentCoordinator: Any?
    private var route: Route?
    
    public init(window: UIWindow) {
        self.rootViewController = Storyboard.root.initial(viewController: RootViewController.self)
        
        window.rootViewController = self.rootViewController
        window.tintColor = UIColor.zap.peach
        
        Appearance.setup()
    }
    
    public func start() {
        _ = Scheduler.schedule(interval: 60 * 10, job: ExchangeUpdaterJob()) // TODO: move this somewhere else?

        switch LndConnection.current {
        case .none:
            presentSetup()
        default:
            if Environment.skipPinFlow || !AuthenticationService.shared.didSetupPin {
                presentLoading(message: .none)
                connect()
            } else {
                presentPin()
            }
        }
    }
    
    public func handle(_ route: Route?) {
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
        guard let lightningService = lightningService else { return }
        let mainCoordinator = MainCoordinator(rootViewController: rootViewController, lightningService: lightningService)
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
        guard let lightningService = lightningService else { fatalError("viewModel not set") }
        let viewController = UIStoryboard.instantiateSyncViewController(with: lightningService)
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
    
    private func startWalletUI(with lightningService: LightningService) {
        startListeningForErrorNotifications()
        
        lightningService.infoService.walletState
            .skip(first: 1)
            .distinct()
            .observeOn(DispatchQueue.main)
            .observeNext { [weak self] state in
                switch state {
                case .locked:
                    self?.presentPin()
                case .connecting:
                    if case .remote = LndConnection.current {
                        lightningService.stop()
                        self?.lightningService = nil
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
            .observeOn(DispatchQueue.main)
            .observeNext { notification in
                guard let message = notification.userInfo?["message"] as? String else { return }
                let toast = Toast(message: message, style: .error)
                UIApplication.topViewController?.presentToast(toast, animated: true, completion: nil)
            }
            .dispose(in: reactive.bag)
    }
    
    internal func connect() {
        guard let api = LndConnection.current.api else { return }
        
        if case .local = LndConnection.current {
            WalletService(wallet: WalletStream()).unlockWallet { _ in }
        }
        
        let lightningService = LightningService(api: api)
        lightningService.start()
        self.lightningService = lightningService
        self.startWalletUI(with: lightningService)
    }
}
