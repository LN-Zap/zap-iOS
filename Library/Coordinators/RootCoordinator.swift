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
    private let connectionService: ConnectionService
    private let authenticationCoordinator: AuthenticationCoordinator
    private let backgroundCoordinator: BackgroundCoordinator
    
    private var currentCoordinator: Any?
    private var route: Route?
    
    var authenticationViewModel: AuthenticationViewModel { // SettingsDelegate
        return authenticationCoordinator.authenticationViewModel
    }
    
    public init(window: UIWindow) {
        rootViewController = Storyboard.root.initial(viewController: RootViewController.self)
        connectionService = ConnectionService()
        authenticationCoordinator = AuthenticationCoordinator(rootViewController: rootViewController)
        backgroundCoordinator = BackgroundCoordinator(rootViewController: rootViewController)
        
        window.rootViewController = self.rootViewController
        window.tintColor = UIColor.Zap.lightningOrange
        Appearance.setup()
        
        super.init()
        start()
        
        updateFor(state: connectionService.state.value)
        listenForStateChanges()
    }
    
    public func listenForStateChanges() {
        connectionService.state
            .skip(first: 1)
            .distinct()
            .observeOn(DispatchQueue.main)
            .observeNext { [weak self] state in
                self?.updateFor(state: state)
            }.dispose(in: reactive.bag)
    }
    
    private func updateFor(state: ConnectionService.State) {
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
        if case .connect(let url) = route {
            openRPCConnectURL(url)
        } else {
            self.route = route
            
            if let mainCoordinator = currentCoordinator as? MainCoordinator {
                mainCoordinator.handle(route)
                self.route = nil
            }
        }
    }
    
    public func applicationWillEnterForeground() {
        backgroundCoordinator.applicationWillEnterForeground()
        start()
    }
    
    private func start() {
        connectionService.start()
        ExchangeUpdaterJob.start()
    }
    
    private func openRPCConnectURL(_ url: RPCConnectURL) {
        let message = L10n.Scene.ConnectNodeUri.ActionSheet.message(url.rpcConfiguration.url.absoluteString)
        let alertController = UIAlertController(title: L10n.Scene.ConnectNodeUri.ActionSheet.title, message: message, preferredStyle: .actionSheet)
        
        let connectAlertAction = UIAlertAction(title: L10n.Scene.ConnectNodeUri.ActionSheet.connectButton, style: .default, handler: { [weak self] _ in
            self?.connectionService.reconnect(configuration: url.rpcConfiguration)
        })
        
        alertController.addAction(connectAlertAction)
        let cancelAlertAction = UIAlertAction(title: L10n.Generic.cancel, style: .cancel, handler: nil)
        alertController.addAction(cancelAlertAction)
        
        rootViewController.dismiss(animated: false)
        rootViewController.present(alertController, animated: true, completion: nil)
    }
    
    public func applicationDidEnterBackground() {
        backgroundCoordinator.applicationDidEnterBackground()
        route = nil // reset route when app enters background
        connectionService.stop()
        ExchangeUpdaterJob.stop()
    }
    
    private func presentMain() {
        guard let lightningService = connectionService.lightningService else { return }
        
        let tabBarController = RootTabBarController()
        
        let mainCoordinator = MainCoordinator(rootViewController: rootViewController, lightningService: lightningService, settingsDelegate: self, authenticationViewModel: authenticationCoordinator.authenticationViewModel)

        tabBarController.viewControllers = [
            mainCoordinator.walletViewController(),
            mainCoordinator.historyViewController(),
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
        let setupCoordinator = SetupCoordinator(rootViewController: rootViewController, connectionService: connectionService, authenticationViewModel: authenticationCoordinator.authenticationViewModel, delegate: self)
        currentCoordinator = setupCoordinator
        setupCoordinator.start()
    }
    
    private func presentSync() {
        guard let lightningService = connectionService.lightningService else { return }
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
        connectionService.connect()
    }
    
    func disconnect() {
        connectionService.disconnect()
    }
}
