//
//  Zap
//
//  Created by Otto Suess on 02.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Lightning
import UIKit

protocol SetupCoordinatorDelegate: class {
    func connect()
    func presentSetupPin()
}

final class SetupCoordinator {
    private let rootViewController: RootViewController
    private let rootViewModel: RootViewModel
    private weak var navigationController: UINavigationController?
    private weak var delegate: SetupCoordinatorDelegate?
    private weak var connectRemoteNodeViewModel: ConnectRemoteNodeViewModel?
    private weak var mnemonicViewModel: MnemonicViewModel?
    
    init(rootViewController: RootViewController, rootViewModel: RootViewModel, delegate: SetupCoordinatorDelegate) {
        self.rootViewController = rootViewController
        self.rootViewModel = rootViewModel
        self.delegate = delegate
    }

    func start() {
        let viewController = UIStoryboard.instantiateSetupViewController(createButtonTapped: createNewWallet, recoverButtonTapped: recoverExistingWallet, connectButtonTapped: connectRemoteNode)
        navigationController = viewController
        self.rootViewController.setContainerContent(viewController)
    }
    
    private func createNewWallet() {
        #if LOCALONLY
        presentDisabledAlert()
        #else
        // TODO: stop Lnd when navigating back to Root
        if !LocalLnd.isRunning {
            LocalLnd.start()
        }
        
        let walletService = rootViewModel.walletService
        let mnemonicViewModel = MnemonicViewModel(walletService: walletService)
        self.mnemonicViewModel = mnemonicViewModel
        
        let viewController = UIStoryboard.instantiateMnemonicViewController(mnemonicViewModel: mnemonicViewModel, presentConfirmMnemonic: confirmMnemonic)
        navigationController?.pushViewController(viewController, animated: true)
        #endif
    }
    
    private func confirmMnemonic() {
        guard
            let confirmMnemonicViewModel = mnemonicViewModel?.confirmMnemonicViewModel,
            let delegate = delegate
            else { return }
        
        let viewController = UIStoryboard.instantiateConfirmMnemonicViewController(confirmMnemonicViewModel: confirmMnemonicViewModel, walletConfirmed: delegate.presentSetupPin)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func recoverExistingWallet() {
        #if LOCALONLY
        presentDisabledAlert()
        #else
        guard let delegate = delegate else { return }
        
        if !LocalLnd.isRunning {
            LocalLnd.start()
        }
        
        let walletService = rootViewModel.walletService
        let viewModel = RecoverWalletViewModel(walletService: walletService)
        let viewController = UIStoryboard.instantiateRecoverWalletViewController(recoverWalletViewModel: viewModel, presentSetupPin: delegate.presentSetupPin)
        navigationController?.pushViewController(viewController, animated: true)
        #endif
    }
    
    private func connectRemoteNode() {
        let viewModel = ConnectRemoteNodeViewModel()
        connectRemoteNodeViewModel = viewModel
        let viewController = UIStoryboard.instantiateConnectRemoteNodeViewController(didSetupWallet: didSetupWallet, connectRemoteNodeViewModel: viewModel, presentQRCodeScannerButtonTapped: presentNodeCertificatesScanner)
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func didSetupWallet() {
        if Environment.skipPinFlow || rootViewModel.authenticationViewModel.didSetupPin {
            delegate?.connect()
        } else {
            delegate?.presentSetupPin()
        }
    }
    
    private func presentNodeCertificatesScanner() {
        guard let connectRemoteNodeViewModel = connectRemoteNodeViewModel else { return }
        let viewController = UIStoryboard.instantiateRemoteNodeCertificatesScannerViewController(connectRemoteNodeViewModel: connectRemoteNodeViewModel)
        navigationController?.present(viewController, animated: true, completion: nil)
    }
    
    private func presentDisabledAlert() {
        let alert = UIAlertController(title: "scene.select_wallet_connection.disabled_alert.title".localized, message: "scene.select_wallet_connection.disabled_alert.message".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        navigationController?.present(alert, animated: true, completion: nil)
    }
}
