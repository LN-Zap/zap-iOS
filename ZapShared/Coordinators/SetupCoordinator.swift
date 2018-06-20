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
    
    init(rootViewController: RootViewController, delegate: SetupCoordinatorDelegate) {
        self.rootViewController = rootViewController
        self.delegate = delegate
    }

    func start() {
        let viewController = UIStoryboard.instantiateSetupViewController(createButtonTapped: createNewWallet, recoverButtonTapped: recoverExistingWallet, connectButtonTapped: connectRemoteNode)
        navigationController = viewController
        DispatchQueue.main.async {
            self.rootViewController.setContainerContent(viewController)
        }
    }
    
    private func createNewWallet() {
        if !Lnd.isRunning {
            Lnd.start()
        }

        let unlocker = WalletStream()
        let mnemonicViewModel = MnemonicViewModel(walletUnlocker: unlocker)

        let viewController = UIStoryboard.instantiateMnemonicViewController(mnemonicViewModel: mnemonicViewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func recoverExistingWallet() {
        let viewController = UIStoryboard.instantiateRecoverWalletViewController()
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
