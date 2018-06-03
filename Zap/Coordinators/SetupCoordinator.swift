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
    private weak var connectRemoteNodeViewController: ConnectRemoteNodeViewController?
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
        presentErrorMessage()
    }
    
    private func recoverExistingWallet() {
        presentErrorMessage()
    }
    
    private func presentErrorMessage() {
        let alertController = UIAlertController(title: "Sorry", message: "Running lnd on the phone is not yet supported in this beta.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        navigationController?.present(alertController, animated: true, completion: nil)
    }
    
    private func connectRemoteNode() {
        let viewModel = ConnectRemoteNodeViewModel()
        connectRemoteNodeViewModel = viewModel
        let viewController = UIStoryboard.instantiateConnectRemoteNodeViewController(didSetupWallet: didSetupWallet, connectRemoteNodeViewModel: viewModel, presentQRCodeScannerButtonTapped: presentNodeCertificatesScanner)
        connectRemoteNodeViewController = viewController
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func didSetupWallet() {
        if Environment.skipPinFlow || AuthenticationViewModel.shared.didSetupPin {
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
