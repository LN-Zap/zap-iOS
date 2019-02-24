//
//  Zap
//
//  Created by Otto Suess on 31.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Lightning
import SwiftLnd
import UIKit

protocol RootCoordinatorDelegate: class {
    func embedInRootContainer(viewController: UIViewController)
}

public final class RootCoordinator: Coordinator {
    let rootViewController: RootViewController
    private let authenticationCoordinator: AuthenticationCoordinator
    private let backgroundCoordinator: BackgroundCoordinator
    private let toastNotificationObserver: ToastNotificationObserver = {
        let observer = ToastNotificationObserver()
        observer.start()
        return observer
    }()

    private let walletConfigurationStore = WalletConfigurationStore.load()

    private var currentCoordinator: Coordinator?
    private var route: Route?

    var authenticationViewModel: AuthenticationViewModel { // SettingsDelegate
        return authenticationCoordinator.authenticationViewModel
    }

    public init(window: UIWindow) {
        rootViewController = StoryboardScene.Root.initialScene.instantiate()
        authenticationCoordinator = AuthenticationCoordinator(rootViewController: rootViewController)
        backgroundCoordinator = BackgroundCoordinator(rootViewController: rootViewController)

        window.rootViewController = self.rootViewController
        window.tintColor = UIColor.Zap.lightningOrange
        Appearance.setup()
    }

    public func start() {
        authenticationCoordinator.start()
        update()
    }

    // MARK: foreground / background state handling

    public func applicationWillEnterForeground() {
        backgroundCoordinator.applicationWillEnterForeground()
    }

    public func applicationDidEnterBackground() {
        backgroundCoordinator.applicationDidEnterBackground()
        route = nil // reset route when app enters background
    }

    // MARK: Coordinator Methods

    private func update() {
        if !authenticationViewModel.didSetupPin {
            presentPinSetup()
        } else if let selectedWallet = walletConfigurationStore.selectedWallet {
            presentSelectedWallet(selectedWallet)
        } else {
            presentSetup(walletConfigurationStore: walletConfigurationStore, remoteRPCConfiguration: nil)
        }
    }

    private func presentSelectedWallet(_ configuration: WalletConfiguration) {
        #if REMOTEONLY
        if configuration.connection == .local {
            walletConfigurationStore.selectedWallet = nil
            update()
            return
        }
        #endif

        guard let lightningService = LightningService(connection: configuration.connection, walletId: configuration.walletId) else { return }

        walletConfigurationStore.selectedWallet = configuration

        walletConfigurationStore.updateInfo(for: configuration, infoService: lightningService.infoService)

        let walletCoordinator = WalletCoordinator(rootViewController: rootViewController, lightningService: lightningService, disconnectWalletDelegate: self, authenticationViewModel: authenticationViewModel, walletConfigurationStore: walletConfigurationStore)
        self.currentCoordinator = walletCoordinator
        walletCoordinator.start()
    }

    private func presentSetup(walletConfigurationStore: WalletConfigurationStore, remoteRPCConfiguration: RemoteRPCConfiguration?) {
        let setupCoordinator = SetupCoordinator(rootViewController: rootViewController, authenticationViewModel: authenticationCoordinator.authenticationViewModel, delegate: self, walletConfigurationStore: walletConfigurationStore, remoteRPCConfiguration: remoteRPCConfiguration)
        currentCoordinator = setupCoordinator
        setupCoordinator.start()
    }

    private func presentPinSetup() {
        let pinSetupCoordinator = PinSetupCoordinator(rootViewController: rootViewController, authenticationViewModel: authenticationViewModel, delegate: self)
        self.currentCoordinator = pinSetupCoordinator
        pinSetupCoordinator.start()
    }
}

extension RootCoordinator: Routing {
    public func handle(_ route: Route) {
        if case .connect(let url) = route {
            openRPCConnectURL(url)
        } else {
            self.route = route

            if let mainCoordinator = currentCoordinator as? WalletCoordinator {
                mainCoordinator.handle(route)
                self.route = nil
            }
        }
    }

    private func openRPCConnectURL(_ url: LndConnectURL) {
        let message = L10n.Scene.ConnectNodeUri.ActionSheet.message(url.rpcConfiguration.url.absoluteString)
        let alertController = UIAlertController(title: L10n.Scene.ConnectNodeUri.ActionSheet.title, message: message, preferredStyle: .actionSheet)

        let connectAlertAction = UIAlertAction(title: L10n.Scene.ConnectNodeUri.ActionSheet.connectButton, style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.disconnect()
            self.presentSetup(walletConfigurationStore: self.walletConfigurationStore, remoteRPCConfiguration: url.rpcConfiguration)
        })

        alertController.addAction(connectAlertAction)
        let cancelAlertAction = UIAlertAction(title: L10n.Generic.cancel, style: .cancel, handler: nil)
        alertController.addAction(cancelAlertAction)

        rootViewController.dismiss(animated: false)
        rootViewController.present(alertController, animated: true, completion: nil)
    }
}

extension RootCoordinator: PinSetupCoordinatorDelegate {
    func didSetupPin() {
        update()
    }
}

extension RootCoordinator: RootCoordinatorDelegate {
    func embedInRootContainer(viewController: UIViewController) {
        rootViewController.setContainerContent(viewController)
    }
}

extension RootCoordinator: SetupCoordinatorDelegate {
    func connectWallet(configuration: WalletConfiguration) {
        presentSelectedWallet(configuration)
    }
}

extension RootCoordinator: DisconnectWalletDelegate {
    func reconnect(walletConfiguration: WalletConfiguration?) {
        if let walletCoordinator = currentCoordinator as? WalletCoordinator {
            walletCoordinator.stop()
            currentCoordinator = nil
            walletConfigurationStore.selectedWallet = walletConfiguration

            update()
        }
    }

    func disconnect() {
        reconnect(walletConfiguration: nil)
    }
}
