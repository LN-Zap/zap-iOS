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
    func connect()
    func presentSetupPin()
}

final class SetupCoordinator {
    private let rootViewController: RootViewController
    private let connectionService: ConnectionService
    private let authenticationViewModel: AuthenticationViewModel
    
    private weak var navigationController: UINavigationController?
    private weak var delegate: SetupCoordinatorDelegate?
    private weak var connectRemoteNodeViewModel: ConnectRemoteNodeViewModel?
    private weak var mnemonicViewModel: MnemonicViewModel?
    
    init(rootViewController: RootViewController, connectionService: ConnectionService, authenticationViewModel: AuthenticationViewModel, delegate: SetupCoordinatorDelegate) {
        self.rootViewController = rootViewController
        self.connectionService = connectionService
        self.authenticationViewModel = authenticationViewModel
        self.delegate = delegate
    }

    func start() {
        let viewController: UIViewController
        #if REMOTEONLY
        let viewModel = ConnectRemoteNodeViewModel()
        connectRemoteNodeViewModel = viewModel
        viewController = ConnectRemoteNodeViewController.instantiate(didSetupWallet: didSetupWallet, connectRemoteNodeViewModel: viewModel, presentQRCodeScannerButtonTapped: presentNodeCertificatesScanner)
        #else
        viewController = SetupViewController.instantiate(createButtonTapped: createNewWallet, recoverButtonTapped: recoverExistingWallet, connectButtonTapped: connectRemoteNode)
        #endif
        
        let navigationController = ZapNavigationController(rootViewController: viewController)
        navigationController.navigationBar.prefersLargeTitles = false
        self.navigationController = navigationController
        self.rootViewController.setContainerContent(navigationController)
    }
    
    private func createNewWallet() {
        #if REMOTEONLY
        presentDisabledAlert()
        #else
        // TODO: stop Lnd when navigating back to Root
        if !LocalLnd.isRunning {
            LocalLnd.start()
        }
        
        let walletService = connectionService.walletService
        let mnemonicViewModel = MnemonicViewModel(walletService: walletService)
        self.mnemonicViewModel = mnemonicViewModel
        
        let viewController = MnemonicViewController.instantiate(mnemonicViewModel: mnemonicViewModel, presentConfirmMnemonic: confirmMnemonic)
        navigationController?.pushViewController(viewController, animated: true)
        #endif
    }
    
    private func confirmMnemonic() {
        guard
            let confirmMnemonicViewModel = mnemonicViewModel?.confirmMnemonicViewModel,
            let delegate = delegate
            else { return }
        
        let viewController = ConfirmMnemonicViewController.instantiate(confirmMnemonicViewModel: confirmMnemonicViewModel, walletConfirmed: delegate.presentSetupPin)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func recoverExistingWallet() {
        #if REMOTEONLY
        presentDisabledAlert()
        #else
        guard let delegate = delegate else { return }
        
        if !LocalLnd.isRunning {
            LocalLnd.start()
        }
        
        let walletService = connectionService.walletService
        let viewModel = RecoverWalletViewModel(walletService: walletService)
        let viewController = RecoverWalletViewController.instantiate(recoverWalletViewModel: viewModel, presentSetupPin: delegate.presentSetupPin)
        navigationController?.pushViewController(viewController, animated: true)
        #endif
    }
    
    private func connectRemoteNode() {
        let viewModel = ConnectRemoteNodeViewModel()
        connectRemoteNodeViewModel = viewModel
        let viewController = ConnectRemoteNodeViewController.instantiate(didSetupWallet: didSetupWallet, connectRemoteNodeViewModel: viewModel, presentQRCodeScannerButtonTapped: presentNodeCertificatesScanner)
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func didSetupWallet() {
        if Environment.skipPinFlow || authenticationViewModel.didSetupPin {
            delegate?.connect()
        } else {
            delegate?.presentSetupPin()
        }
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
}
