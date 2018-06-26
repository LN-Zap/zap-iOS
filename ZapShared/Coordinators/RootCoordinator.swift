//
//  Zap
//
//  Created by Otto Suess on 31.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

public final class RootCoordinator: NSObject, SetupCoordinatorDelegate, PinCoordinatorDelegate {
    
    private let rootViewController: RootViewController
    private let zapService: ZapService
    
    private var currentCoordinator: Any?
    private var route: Route?
    
    public init(window: UIWindow) {
        rootViewController = Storyboard.root.initial(viewController: RootViewController.self)
        zapService = ZapService()
        
        window.rootViewController = self.rootViewController
        window.tintColor = UIColor.zap.peach
        
        Appearance.setup()
        
        zapService.start()
    }
    
    public func start() {
        startListeningForErrorNotifications()
        
        zapService.state.observeNext { [weak self] state in
            switch state {
            case .locked:
                self?.presentPin()
            case .noWallet:
                self?.presentSetup()
            case .loading(let message):
                self?.presentLoading(message: message)
            case .syncing:
                self?.presentSync()
            case .running:
                self?.presentMain()
            }
        }.dispose(in: reactive.bag)
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
        guard let lightningService = zapService.lightningService else { return }
        let mainCoordinator = MainCoordinator(rootViewController: rootViewController, lightningService: lightningService)
        currentCoordinator = mainCoordinator
        mainCoordinator.start()
                
        if let route = self.route {
            handle(route)
        }
    }
    
    private func presentSetup() {
        let setupCoordinator = SetupCoordinator(rootViewController: rootViewController, zapService: zapService, delegate: self)
        currentCoordinator = setupCoordinator
        setupCoordinator.start()
    }
    
    private func presentSync() {
        guard let lightningService = zapService.lightningService else { fatalError("viewModel not set") }
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
    
    func connect() {
        zapService.connect()
    }
}
