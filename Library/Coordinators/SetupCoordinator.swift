//
//  Zap
//
//  Created by Otto Suess on 02.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Lightning
import SwiftLnd
import UIKit

protocol SetupCoordinatorDelegate: class {
    func connectWallet(configuration: WalletConfiguration)
}

final class SetupCoordinator: Coordinator {
    let rootViewController: RootViewController
    private let authenticationViewModel: AuthenticationViewModel
    private let walletConfigurationStore: WalletConfigurationStore
    private let rpcCredentials: RPCCredentials?

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
    private func createLocalWallet() -> WalletConfiguration {
        let configuration = WalletConfiguration.local(network: .testnet)
        LocalLnd.start(walletId: configuration.walletId)
        return configuration
    }
    #endif

    private func createNewWallet() {
        #if REMOTEONLY
        presentDisabledAlert()
        #else

        let configuration = createLocalWallet()

        let mnemonicViewModel = MnemonicViewModel(configuration: configuration)
        self.mnemonicViewModel = mnemonicViewModel

        let viewController = MnemonicViewController.instantiate(mnemonicViewModel: mnemonicViewModel, presentConfirmMnemonic: confirmMnemonic)
        navigationController?.pushViewController(viewController, animated: true)
        #endif
    }

    private func confirmMnemonic() {
        guard let confirmMnemonicViewModel = mnemonicViewModel?.confirmMnemonicViewModel else { return }

        let viewController = ConfirmMnemonicViewController.instantiate(confirmMnemonicViewModel: confirmMnemonicViewModel, connectWallet: didSetupWallet)
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func recoverExistingWallet() {
        #if !REMOTEONLY
        guard let delegate = delegate else { return }

        let configuration = createLocalWallet()

        let viewModel = RecoverWalletViewModel(configuration: configuration)
        let viewController = RecoverWalletViewController.instantiate(recoverWalletViewModel: viewModel, connectWallet: delegate.connectWallet)
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

    private func didSetupWallet(configuration: WalletConfiguration) {
        walletConfigurationStore.addWallet(walletConfiguration: configuration)
        delegate?.connectWallet(configuration: configuration)
    }

    private func presentNodeCertificatesScanner() {
        guard let connectRemoteNodeViewModel = connectRemoteNodeViewModel else { return }
        let viewController = RemoteNodeCertificatesScannerViewController.instantiate(connectRemoteNodeViewModel: connectRemoteNodeViewModel)
        navigationController?.present(viewController, animated: true, completion: nil)
    }

    private func walletListViewController() -> ManageWalletsViewController {
        return ManageWalletsViewController.instantiate(addWalletButtonTapped: { [weak self] in
            guard let self = self else { return }
            self.navigationController?.pushViewController(self.setupWalletViewController(), animated: true)
        }, walletConfigurationStore: walletConfigurationStore, connectWallet: connectWallet)
    }

    private func setupWalletViewController() -> UIViewController {
        #if REMOTEONLY
        return connectRemoteNodeViewController(rpcCredentials: nil)
        #else
        if walletConfigurationStore.hasLocalWallet {
            return connectRemoteNodeViewController(rpcCredentials: nil)
        } else {
            return SelectWalletCreationMethodViewController.instantiate(createButtonTapped: createNewWallet, recoverButtonTapped: recoverExistingWallet, connectButtonTapped: connectRemoteNode)
        }
        #endif
    }

    private func connectRemoteNodeViewController(rpcCredentials: RPCCredentials?) -> ConnectRemoteNodeViewController {
        let viewModel = ConnectRemoteNodeViewModel(rpcCredentials: rpcCredentials)
        connectRemoteNodeViewModel = viewModel
        return ConnectRemoteNodeViewController.instantiate(didSetupWallet: didSetupWallet, connectRemoteNodeViewModel: viewModel, presentQRCodeScannerButtonTapped: presentNodeCertificatesScanner)
    }

    private func connectWallet(_ walletConfiguration: WalletConfiguration) {
        delegate?.connectWallet(configuration: walletConfiguration)
    }
}
