//
//  Zap
//
//  Created by Otto Suess on 31.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Lightning
import Logger
import SwiftLnd
import UIKit

protocol RootCoordinatorDelegate: class {
    func embedInRootContainer(viewController: UIViewController)
}

protocol DisconnectWalletDelegate: class {
    func disconnect()
}

protocol ReconnectWalletDelegate: class {
    func reconnect(walletConfiguration: WalletConfiguration?)
}

typealias WalletDelegate = (DisconnectWalletDelegate & ReconnectWalletDelegate)

public final class RootCoordinator: Coordinator, SetupCoordinatorDelegate {
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

    public func applicationDidBecomeActive() {
        Logger.info("applicationDidBecomeActive", customPrefix: "🎬")
        backgroundCoordinator.applicationDidBecomeActive()
        authenticationCoordinator.applicationDidBecomeActive()

        if let walletCoordinator = currentCoordinator as? WalletCoordinator {
            walletCoordinator.start()
        }
    }

    public func applicationDidEnterBackground() {
        backgroundCoordinator.applicationDidEnterBackground()
        route = nil // reset route when app enters background

        if let walletCoordinator = currentCoordinator as? WalletCoordinator {
            walletCoordinator.stop()
        }
    }

    // MARK: Coordinator Methods

    private func update() {
        if !PinStore.didSetupPin {
            presentPinSetup()
        } else if let selectedWallet = walletConfigurationStore.selectedWallet {
            presentWallet(connection: selectedWallet.connection) { [weak self, walletConfigurationStore] result in
                guard case .failure = result else { return }
                self?.presentSetup(walletConfigurationStore: walletConfigurationStore, rpcCredentials: nil)
            }
        } else {
            presentSetup(walletConfigurationStore: walletConfigurationStore, rpcCredentials: nil)
        }
    }

    func presentWallet(connection: LightningConnection, completion: @escaping (Result<Success, Error>) -> Void) {
        if case .remote(let credentials) = connection, credentials.host.isOnion {
            rootViewController.setContainerContent(LoadingViewController.instantiate())
            
            OnionConnecter().start(progress: nil, completion: { [weak self] result in
                switch result {
                case .success(let urlSessionConfiguration):
                    let api = LightningApi(connection: .tor(credentials, urlSessionConfiguration))
                    let lightningService = LightningService(
                        api: api,
                        connection: connection,
                        backupService: StaticChannelBackupService()
                    )

                    DispatchQueue.main.async {
                        self?.presentWallet(lightningService: lightningService, connection: connection)
                        completion(.success(Success()))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        } else {
            do {
                let lightningService = try LightningService(connection: connection, backupService: StaticChannelBackupService())
                presentWallet(lightningService: lightningService, connection: connection)
                completion(.success(Success()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    private func presentWallet(lightningService: LightningService, connection: LightningConnection) {
        walletConfigurationStore.updateConnection(connection, infoService: lightningService.infoService)

        let walletCoordinator = WalletCoordinator(rootViewController: rootViewController, lightningService: lightningService, disconnectWalletDelegate: self, authenticationViewModel: authenticationViewModel, walletConfigurationStore: walletConfigurationStore)
        self.currentCoordinator = walletCoordinator
        walletCoordinator.start()
    }

    private func presentSetup(walletConfigurationStore: WalletConfigurationStore, rpcCredentials: RPCCredentials?) {
        let setupCoordinator = SetupCoordinator(rootViewController: rootViewController, authenticationViewModel: authenticationCoordinator.authenticationViewModel, delegate: self, walletConfigurationStore: walletConfigurationStore, rpcCredentials: rpcCredentials)
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
        let message = L10n.Scene.ConnectNodeUri.ActionSheet.message(url.rpcCredentials.host.absoluteString)
        let alertController = UIAlertController(title: L10n.Scene.ConnectNodeUri.ActionSheet.title, message: message, preferredStyle: .actionSheet)

        let connectAlertAction = UIAlertAction(title: L10n.Scene.ConnectNodeUri.ActionSheet.connectButton, style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.disconnect()
            self.presentSetup(walletConfigurationStore: self.walletConfigurationStore, rpcCredentials: url.rpcCredentials)
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

extension RootCoordinator: ReconnectWalletDelegate {
    func reconnect(walletConfiguration: WalletConfiguration?) {
        guard let walletCoordinator = currentCoordinator as? WalletCoordinator else { return }

        walletCoordinator.stop()
        currentCoordinator = nil
        walletConfigurationStore.selectedWallet = walletConfiguration

        update()
    }
}

extension RootCoordinator: DisconnectWalletDelegate {
    func disconnect() {
        reconnect(walletConfiguration: nil)
    }
}
