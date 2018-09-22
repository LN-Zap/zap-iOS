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
    private let authenticationCoordinator: AuthenticationCoordinator
    private let backgroundCoordinator: BackgroundCoordinator
    
    private var currentCoordinator: Any?
    private var route: Route?
    
    var authenticationViewModel: AuthenticationViewModel { // SettingsDelegate
        return authenticationCoordinator.authenticationViewModel
    }
    
    public init(window: UIWindow) {
        rootViewController = Storyboard.root.initial(viewController: RootViewController.self)
        rootViewModel = RootViewModel()
        authenticationCoordinator = AuthenticationCoordinator(rootViewController: rootViewController)
        backgroundCoordinator = BackgroundCoordinator(rootViewController: rootViewController)
        
        window.rootViewController = self.rootViewController
        window.tintColor = UIColor.Zap.lightningOrange
        Appearance.setup()
        
        rootViewModel.start()
        super.init()
        
        updateFor(state: rootViewModel.state.value)
        listenForStateChanges()
    }
    
    public func listenForStateChanges() {
        rootViewModel.state
            .skip(first: 1)
            .distinct()
            .observeOn(DispatchQueue.main)
            .observeNext { [weak self] state in
                self?.updateFor(state: state)
            }.dispose(in: reactive.bag)
    }
    
    private func updateFor(state: RootViewModel.State) {
        print("🗽 state:", state)

        switch state {
        case .noWallet:
            presentSetup()
        case .connecting:
            presentLoading(message: .none)
        case .noInternet:
            presentLoading(message: .noInternet)
        case .syncing:
            presentSync()
        case .running:
            presentMain()
        }
    }
    
    public func handle(_ route: Route) {
        self.route = route
        
        if let mainCoordinator = currentCoordinator as? MainCoordinator {
            mainCoordinator.handle(route)
            self.route = nil
        }
    }
    
    public func applicationWillEnterForeground() {
        backgroundCoordinator.applicationWillEnterForeground()
        rootViewModel.start()
    }
    
    public func applicationDidEnterBackground() {
        backgroundCoordinator.applicationDidEnterBackground()
        route = nil // reset route when app enters background
        rootViewModel.stop()
    }
    
    private func presentMain() {
        guard let lightningService = rootViewModel.lightningService else { return }
        
        let tabBarController = RootTabBarController()
        
        let mainCoordinator = MainCoordinator(rootViewController: rootViewController, lightningService: lightningService, settingsDelegate: self, authenticationViewModel: authenticationCoordinator.authenticationViewModel)

        tabBarController.viewControllers = [
            mainCoordinator.walletViewController(),
            mainCoordinator.historyViewController(),
            mainCoordinator.channelListViewController(),
            mainCoordinator.settingsViewController()
        ]
        presentViewController(tabBarController)
    
        currentCoordinator = mainCoordinator

        mainCoordinator.historyViewModel.setupTabBarBadge(delegate: tabBarController)
        
        if let route = self.route {
            handle(route)
        }
    }
    
    private func presentSetup() {
        let setupCoordinator = SetupCoordinator(rootViewController: rootViewController, rootViewModel: rootViewModel, authenticationViewModel: authenticationCoordinator.authenticationViewModel, delegate: self)
        currentCoordinator = setupCoordinator
        setupCoordinator.start()
    }
    
    private func presentSync() {
        guard let lightningService = rootViewModel.lightningService else { return }
        let viewController = UIStoryboard.instantiateSyncViewController(with: lightningService, delegate: self)
        presentViewController(viewController)
    }
    
    private func presentLoading(message: LoadingViewController.Message) {
        let viewController = UIStoryboard.instantiateLoadingViewController(message: message)
        presentViewController(viewController)
    }
    
    internal func presentSetupPin() {
        let pinSetupCoordinator = PinSetupCoordinator(rootViewController: rootViewController, authenticationViewModel: authenticationCoordinator.authenticationViewModel, delegate: self)
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
