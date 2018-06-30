//
//  Zap
//
//  Created by Otto Suess on 31.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Lightning
import UIKit

public final class RootCoordinator: NSObject, SetupCoordinatorDelegate, PinCoordinatorDelegate {
    
    private let rootViewController: RootViewController
    private let rootViewModel: RootViewModel
    
    private var currentCoordinator: Any?
    private var route: Route?
    
    public init(window: UIWindow) {
        rootViewController = Storyboard.root.initial(viewController: RootViewController.self)
        rootViewModel = RootViewModel()
        
        window.rootViewController = self.rootViewController
        window.tintColor = UIColor.zap.peach
        
        Appearance.setup()
        
        rootViewModel.start()
    }
    
    public func start() {
        ExchangeUpdaterJob.start()

        rootViewModel.state.observeNext { [weak self] state in
            switch state {
            case .locked:
                self?.presentPin()
            case .noWallet:
                self?.presentSetup()
            case .connecting:
                self?.presentLoading(message: .none)
            case .noInternet:
                self?.presentLoading(message: .noInternet)
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
        guard let lightningService = rootViewModel.lightningService else { return }
        let mainCoordinator = MainCoordinator(rootViewController: rootViewController, lightningService: lightningService)
        currentCoordinator = mainCoordinator
        mainCoordinator.start()
                
        if let route = self.route {
            handle(route)
        }
    }
    
    private func presentSetup() {
        let setupCoordinator = SetupCoordinator(rootViewController: rootViewController, rootViewModel: rootViewModel, delegate: self)
        currentCoordinator = setupCoordinator
        setupCoordinator.start()
    }
    
    private func presentSync() {
        guard let lightningService = rootViewModel.lightningService else { fatalError("viewModel not set") }
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
    
    func connect() {
        rootViewModel.connect()
    }
}
