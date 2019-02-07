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

final class SetupCoordinator {
    private let rootViewController: RootViewController
    private let authenticationViewModel: AuthenticationViewModel
    private let walletConfigurationStore: WalletConfigurationStore
    
    private weak var navigationController: UINavigationController?
    private weak var delegate: SetupCoordinatorDelegate?
    private weak var connectRemoteNodeViewModel: ConnectRemoteNodeViewModel?
    private weak var mnemonicViewModel: MnemonicViewModel?
    
    init(rootViewController: RootViewController, authenticationViewModel: AuthenticationViewModel, delegate: SetupCoordinatorDelegate, walletConfigurationStore: WalletConfigurationStore) {
        self.rootViewController = rootViewController
        self.authenticationViewModel = authenticationViewModel
        self.delegate = delegate
        self.walletConfigurationStore = walletConfigurationStore
    }

    func start(remoteRPCConfiguration: RemoteRPCConfiguration?) {
        let viewController = walletConfigurationStore.isEmpty ? setupWalletViewController() : walletListViewController()
        
        let navigationController = ZapNavigationController(rootViewController: viewController)
        navigationController.navigationBar.prefersLargeTitles = false
        
        self.navigationController = navigationController
        self.rootViewController.setContainerContent(navigationController)
        
        if let remoteRPCConfiguration = remoteRPCConfiguration {
            connectRemoteNode(remoteRPCConfiguration)
        }
    }
    
    #if !REMOTEONLY
    private func startNewLnd() -> WalletConfiguration {
        let configuration = WalletConfiguration(alias: nil, network: nil, connection: .local, walletId: UUID().uuidString)
        
        if !LocalLnd.isRunning {
            LocalLnd.start(walletId: configuration.walletId)
        }
        
        return configuration
    }
    #endif
    
    private func createNewWallet() {
        #if REMOTEONLY
        presentDisabledAlert()
        #else
        
        let configuration = startNewLnd()
        
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
        #if REMOTEONLY
        presentDisabledAlert()
        #else
        guard let delegate = delegate else { return }
        
        let configuration = startNewLnd()
        
        let viewModel = RecoverWalletViewModel(configuration: configuration)
        let viewController = RecoverWalletViewController.instantiate(recoverWalletViewModel: viewModel, connectWallet: delegate.connectWallet)
        navigationController?.pushViewController(viewController, animated: true)
        #endif
    }
    
    private func connectRemoteNode(_ remoteRPCConfiguration: RemoteRPCConfiguration) {
        let viewModel = ConnectRemoteNodeViewModel(remoteRPCConfiguration: remoteRPCConfiguration)
        connectRemoteNodeViewModel = viewModel
        let viewController = ConnectRemoteNodeViewController.instantiate(didSetupWallet: didSetupWallet, connectRemoteNodeViewModel: viewModel, presentQRCodeScannerButtonTapped: presentNodeCertificatesScanner)
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
    
    private func presentDisabledAlert() {
        let alert = UIAlertController(title: L10n.Scene.SelectWalletConnection.DisabledAlert.title, message: L10n.Scene.SelectWalletConnection.DisabledAlert.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.Scene.SelectWalletConnection.DisabledAlert.okButton, style: .cancel, handler: nil))
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
    private func walletListViewController() -> ManageWalletsViewController {
        return ManageWalletsViewController.instantiate(addWalletButtonTapped: { [weak self] in
            guard let self = self else { return }
            self.navigationController?.pushViewController(self.setupWalletViewController(), animated: true)
        }, walletConfigurationStore: walletConfigurationStore, connectWallet: connectWallet)
    }
    
    private func setupWalletViewController() -> UIViewController {
        #if REMOTEONLY
        let viewModel = ConnectRemoteNodeViewModel(remoteRPCConfiguration: nil)
        connectRemoteNodeViewModel = viewModel
        return ConnectRemoteNodeViewController.instantiate(didSetupWallet: didSetupWallet, connectRemoteNodeViewModel: viewModel, presentQRCodeScannerButtonTapped: presentNodeCertificatesScanner)
        #else
        return SelectWalletCreationMethodViewController.instantiate(createButtonTapped: createNewWallet, recoverButtonTapped: recoverExistingWallet, connectButtonTapped: connectRemoteNode)
        #endif
    }

    private func connectWallet(_ walletConfiguration: WalletConfiguration) {
        delegate?.connectWallet(configuration: walletConfiguration)
    }
}
