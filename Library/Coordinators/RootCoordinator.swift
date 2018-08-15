//
//  Zap
//
//  Created by Otto Suess on 31.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Lightning
import UIKit

public final class RootCoordinator: NSObject, SetupCoordinatorDelegate, PinCoordinatorDelegate, SettingsDelegate, SyncDelegate, Routing {
    
    private let rootViewController: RootViewController
    private let rootViewModel: RootViewModel

    private var currentCoordinator: Any?
    private var route: Route?
    
    public init(window: UIWindow) {
        rootViewController = Storyboard.root.initial(viewController: RootViewController.self)
        rootViewModel = RootViewModel()
        
        window.rootViewController = self.rootViewController
        window.tintColor = UIColor.Zap.lightningOrange
        Appearance.setup()
        
        rootViewModel.start()
        super.init()
        listenForStateChanges()
    }
    
    public func listenForStateChanges() {
        rootViewModel.state
            .distinct()
            .observeOn(DispatchQueue.main)
            .observeNext { [weak self] state in
                print("🗽 state:", state)
                switch state {
                case .locked:
                    if self?.rootViewModel.authenticationViewModel.didSetupPin == true {
                        self?.presentPin()
                    } else {
                        self?.presentSetupPin()
                    }
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
    
    public func handle(_ route: Route) {
        self.route = route
        
        if let mainCoordinator = currentCoordinator as? MainCoordinator {
            mainCoordinator.handle(route)
            self.route = nil
        }
    }
    
    public func applicationWillEnterForeground() {
        rootViewController.removeBlurEffect()
        rootViewModel.start()
    }
    
    public func applicationDidEnterBackground() {
        rootViewController.addBlurEffect()
        route = nil // reset route when app enters background
        rootViewModel.stop()
    }
    
    private func presentMain() {
        guard let lightningService = rootViewModel.lightningService else { return }
        
        let tabBarController = UITabBarController()
        tabBarController.tabBar.barTintColor = UIColor.Zap.deepSeaBlue
        tabBarController.tabBar.isTranslucent = false
        tabBarController.tabBar.shadowImage = UIImage()
        tabBarController.tabBar.backgroundImage = UIImage()
        
        let mainCoordinator = MainCoordinator(rootViewController: rootViewController, lightningService: lightningService, settingsDelegate: self)

        tabBarController.viewControllers = [
            mainCoordinator.walletViewController(),
            mainCoordinator.transactionListViewController(),
            mainCoordinator.channelListViewController(),
            mainCoordinator.settingsViewController()
        ]
        presentViewController(tabBarController)
    
        currentCoordinator = mainCoordinator

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
        let viewController = UIStoryboard.instantiateSyncViewController(with: lightningService, delegate: self)
        presentViewController(viewController)
    }
    
    private func presentLoading(message: LoadingViewController.Message) {
        let viewController = UIStoryboard.instantiateLoadingViewController(message: message)
        presentViewController(viewController)
    }
    
    private func presentPin() {
        let pinCoordinator = PinCoordinator(rootViewController: rootViewController, authenticationViewModel: rootViewModel.authenticationViewModel, delegate: self)
        currentCoordinator = pinCoordinator
        pinCoordinator.start()
    }
    
    internal func presentSetupPin() {
        let pinSetupCoordinator = PinSetupCoordinator(rootViewController: rootViewController, authenticationViewModel: rootViewModel.authenticationViewModel, delegate: self)
        currentCoordinator = pinSetupCoordinator
        pinSetupCoordinator.start()
    }
    
    private func presentViewController(_ viewController: UIViewController) {
        self.rootViewController.setContainerContent(viewController)
    }
    
    func connect() {
        rootViewModel.connect()
    }
    
    func disconnect() {
        rootViewModel.disconnect()
    }
}
