//
//  Zap
//
//  Created by Otto Suess on 02.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Lightning
import Logger
import SwiftBTC
import SwiftLnd
import UIKit

protocol SetupCoordinatorDelegate: class {
    func presentWallet(connection: LightningConnection, completion: @escaping (Result<Success, Error>) -> Void)
}

final class SetupCoordinator: Coordinator {
    let rootViewController: RootViewController
    private let authenticationViewModel: AuthenticationViewModel
    private let walletConfigurationStore: WalletConfigurationStore
    private let rpcCredentials: RPCCredentials?

    private weak var createWalletNavigationController: UINavigationController?
    private weak var navigationController: UINavigationController?
    private weak var delegate: SetupCoordinatorDelegate?
    private weak var connectRemoteNodeViewModel: ConnectRemoteNodeViewModel?
    private weak var mnemonicViewModel: MnemonicViewModel?

    init(rootViewController: RootViewController, authenticationViewModel: AuthenticationViewModel, delegate: SetupCoordinatorDelegate, walletConfigurationStore: WalletConfigurationStore, rpcCredentials: RPCCredentials?) {
        self.rootViewController = rootViewController
        self.authenticationViewModel = authenticationViewModel
        self.delegate = delegate
        self.walletConfigurationStore = walletConfigurationStore
        self.rpcCredentials = rpcCredentials
    }

    func start() {
        let viewController = walletConfigurationStore.isEmpty ? setupWalletViewController() : walletListViewController()

        let navigationController = ZapNavigationController(rootViewController: viewController)
        navigationController.navigationBar.prefersLargeTitles = false

        self.navigationController = navigationController
        self.rootViewController.setContainerContent(navigationController)

        if let rpcCredentials = rpcCredentials {
            connectRemoteNode(rpcCredentials)
        }
    }

    #if !REMOTEONLY
    private func startLocalWallet() {
        let network = BuildConfiguration.network
        LocalLnd.start(network: network)
    }
    #endif

    private func createNewLocalWallet() {
        #if !REMOTEONLY
        // start syncing process in background
        startLocalWallet()

        let onboardingViewController = OnboardingContainerViewController.instantiate { [weak self] in
            self?.presentMnemonic(connection: .local)
        }
        let viewController = UINavigationController(rootViewController: onboardingViewController)
        createWalletNavigationController = viewController
        self.navigationController?.present(viewController, animated: true, completion: nil)
        #endif
    }

    private func presentMnemonic(connection: LightningConnection) {
        let mnemonicViewModel = MnemonicViewModel(connection: connection)
        self.mnemonicViewModel = mnemonicViewModel

        let viewController = MnemonicViewController.instantiate(mnemonicViewModel: mnemonicViewModel, presentConfirmMnemonic: presentConfirmMnemonic)
        createWalletNavigationController?.pushViewController(viewController, animated: true)
    }

    private func presentConfirmMnemonic() {
        guard let viewModel = mnemonicViewModel?.confirmMnemonicViewModel else { return }

        let viewController = ConfirmMnemonicPageViewController.instantiate(confirmMnemonicViewModel: viewModel) { [weak self] in
            self?.presentPushNotificationSetup(connection: .local)
        }
        createWalletNavigationController?.pushViewController(viewController, animated: true)
    }

    private func presentPushNotificationSetup(connection: LightningConnection) {
        if NotificationScheduler.needsAuthorization {
            let viewController = PushNotificationViewController.instantiate { [weak self] in
                self?.didSetupWallet(connection: connection)
            }
            createWalletNavigationController?.pushViewController(viewController, animated: true)
        } else {
            didSetupWallet(connection: connection)
        }
    }

    private func recoverExistingWallet() {
        #if !REMOTEONLY
        startLocalWallet()

        let viewModel = RecoverWalletViewModel(connection: .local)
        let viewController = RecoverWalletViewController.instantiate(recoverWalletViewModel: viewModel, connectWallet: connectWallet)
        navigationController?.pushViewController(viewController, animated: true)
        #endif
    }

    private func connectRemoteNode() {
        connectRemoteNode(nil)
    }

    private func connectRemoteNode(_ rpcCredentials: RPCCredentials?) {
        let viewController = connectRemoteNodeViewController(rpcCredentials: rpcCredentials)
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func didSetupWallet(connection: LightningConnection) {
        delegate?.presentWallet(connection: connection) { [weak self] result in
            switch result {
            case .success:
                self?.createWalletNavigationController?.dismiss(animated: true, completion: nil)
            case .failure(let error):
                Logger.error(error)
            }
        }
    }

    private func presentNodeCertificatesScanner() {
        guard let connectRemoteNodeViewModel = connectRemoteNodeViewModel else { return }
        let viewController = RemoteNodeCertificatesScannerViewController.instantiate(connectRemoteNodeViewModel: connectRemoteNodeViewModel)
        navigationController?.present(viewController, animated: true, completion: nil)
    }

    private func walletListViewController() -> ManageWalletsViewController {
        let viewModel = ManageWalletsViewModel(walletConfigurationStore: walletConfigurationStore)
        return ManageWalletsViewController.instantiate(addWalletButtonTapped: { [weak self] in
            guard let self = self else { return }
            self.navigationController?.pushViewController(self.setupWalletViewController(), animated: true)
        }, manageWalletsViewModel: viewModel, connectWallet: connectWallet)
    }

    private func setupWalletViewController() -> UIViewController {
        #if REMOTEONLY
        return connectRemoteNodeViewController(rpcCredentials: nil)
        #else
        if walletConfigurationStore.hasLocalWallet {
            return connectRemoteNodeViewController(rpcCredentials: nil)
        } else {
            return SelectWalletCreationMethodViewController.instantiate(createButtonTapped: createNewLocalWallet, recoverButtonTapped: recoverExistingWallet, connectButtonTapped: connectRemoteNode)
        }
        #endif
    }

    private func connectRemoteNodeViewController(rpcCredentials: RPCCredentials?) -> ConnectRemoteNodeViewController {
        let viewModel = ConnectRemoteNodeViewModel(rpcCredentials: rpcCredentials)
        connectRemoteNodeViewModel = viewModel
        return ConnectRemoteNodeViewController.instantiate(didSetupWallet: didSetupWallet, connectRemoteNodeViewModel: viewModel, presentQRCodeScannerButtonTapped: presentNodeCertificatesScanner)
    }

    private func connectWallet(_ connection: LightningConnection) {
        delegate?.presentWallet(connection: connection) { result in
            guard case .failure(let error) = result else { return }
            Logger.error(error)
        }
    }
}
