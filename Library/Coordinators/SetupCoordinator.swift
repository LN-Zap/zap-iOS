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
    private func createLocalWallet() -> WalletConfiguration {
        let configuration = WalletConfiguration.local(network: .testnet)
        LocalLnd.start(walletId: configuration.walletId)
        return configuration
    }
    #endif

    var configuration: WalletConfiguration?

    private func createNewWallet() {
        #if !REMOTEONLY
        // start syncing process in background
        if configuration == nil {
            configuration = createLocalWallet()
        }

        let pages = [
            OnboardingTextViewController.instantiate(title: "Your key, your coins.", message: "With Zap, you are in control of your money. To make sure your coins are always stored safely, zap will provide a recovery seed for you.", image: Emoji.image(emoji: "🤴")),
            OnboardingTextViewController.instantiate(title: "Write down your recovery seed.", message: "Write down  the recovery seed on a piece of paper. You can recover your funds anytime if your phone goes missing.", image: Emoji.image(emoji: "✍️")),
            OnboardingTextViewController.instantiate(title: "Make sure to keep it in a safe place.", message: "Make sure to keep your recovery seed private. Store it somewhere only you will find it.", image: Emoji.image(emoji: "🗝"), action: { [weak self] in
                self?.presentMnemonic()
            })
        ]

        let onboardingViewController = OnboardingContainerViewController.instantiate(pages: pages)
        let viewController = UINavigationController(rootViewController: onboardingViewController)
        createWalletNavigationController = viewController
        self.navigationController?.present(viewController, animated: true, completion: nil)
        #endif
    }

    private func presentMnemonic() {
        guard let configuration = configuration else { return }

        let mnemonicViewModel = MnemonicViewModel(configuration: configuration)
        self.mnemonicViewModel = mnemonicViewModel

        let viewController = MnemonicViewController.instantiate(mnemonicViewModel: mnemonicViewModel, presentConfirmMnemonic: presentConfirmMnemonic)
        createWalletNavigationController?.pushViewController(viewController, animated: true)
    }

    private func presentConfirmMnemonic() {
        guard let confirmMnemonicViewModel = mnemonicViewModel?.confirmMnemonicViewModel else { return }

        let viewController = ConfirmMnemonicViewController.instantiate(confirmMnemonicViewModel: confirmMnemonicViewModel, connectWallet: didSetupWallet)
        createWalletNavigationController?.pushViewController(viewController, animated: true)
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
        createWalletNavigationController?.dismiss(animated: true, completion: nil)
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
