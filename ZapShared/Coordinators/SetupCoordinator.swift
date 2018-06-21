//
//  Zap
//
//  Created by Otto Suess on 02.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

protocol SetupCoordinatorDelegate: class {
    func connect()
    func presentSetupPin()
}

final class SetupCoordinator {
    private let rootViewController: RootViewController
    private weak var navigationController: UINavigationController?
    private weak var delegate: SetupCoordinatorDelegate?
    private weak var connectRemoteNodeViewModel: ConnectRemoteNodeViewModel?
    private weak var mnemonicViewModel: MnemonicViewModel?
    
    init(rootViewController: RootViewController, delegate: SetupCoordinatorDelegate) {
        self.rootViewController = rootViewController
        self.delegate = delegate
    }

    func start() {
        let viewController = UIStoryboard.instantiateSetupViewController(createButtonTapped: createNewWallet, recoverButtonTapped: recoverExistingWallet, connectButtonTapped: connectRemoteNode)
        navigationController = viewController
        self.rootViewController.setContainerContent(viewController)
    }
    
    private func createNewWallet() {
        // TODO: stop Lnd when navigating back to Root
        if !Lnd.isRunning {
            Lnd.start()
        }

        let wallet = WalletStream()
        let mnemonicViewModel = MnemonicViewModel(wallet: wallet)
        self.mnemonicViewModel = mnemonicViewModel
        
        let viewController = UIStoryboard.instantiateMnemonicViewController(mnemonicViewModel: mnemonicViewModel, presentConfirmMnemonic: confirmMnemonic)
        navigationController?.pushViewController(viewController, animated: true)
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
        guard let delegate = delegate else { return }

        if !Lnd.isRunning {
            Lnd.start()
        }
        
        let wallet = WalletStream()
        let viewModel = RecoverWalletViewModel(wallet: wallet)
        let viewController = UIStoryboard.instantiateRecoverWalletViewController(recoverWalletViewModel: viewModel, presentSetupPin: delegate.presentSetupPin)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func connectRemoteNode() {
        let viewModel = ConnectRemoteNodeViewModel()
        connectRemoteNodeViewModel = viewModel
        let viewController = UIStoryboard.instantiateConnectRemoteNodeViewController(didSetupWallet: didSetupWallet, connectRemoteNodeViewModel: viewModel, presentQRCodeScannerButtonTapped: presentNodeCertificatesScanner)
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func didSetupWallet() {
        if Environment.skipPinFlow || AuthenticationService.shared.didSetupPin {
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
}
