//
//  Zap
//
//  Created by Otto Suess on 31.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static func instantiateMainViewController(with viewModel: ViewModel) -> MainViewController {
        let mainViewController = Storyboard.main.instantiate(viewController: MainViewController.self)
        mainViewController.viewModel = viewModel
        return mainViewController
    }
    
    static func instantiateSetupViewController(with delegate: SetupWalletDelegate) -> UINavigationController {
        let navigationController = Storyboard.createWallet.initial(viewController: UINavigationController.self)
        if let setupWalletViewController = navigationController.topViewController as? SelectWalletCreationMethodViewController {
            setupWalletViewController.delegate = delegate
        }
        return navigationController
    }
    
    static func instantiateSyncViewController(with viewModel: ViewModel) -> SyncViewController {
        let syncViewController = Storyboard.sync.initial(viewController: SyncViewController.self)
        syncViewController.viewModel = viewModel
        return syncViewController
    }
    
    static func instantiateLoadingViewController(with: LoadingViewController.Message) -> LoadingViewController {
        return Storyboard.loading.initial(viewController: LoadingViewController.self)
    }
    
    static func instantiatePinViewController(with delegate: PinViewDelegate) -> PinViewController {
        let pinViewController = Storyboard.numericKeyPad.initial(viewController: PinViewController.self)
        pinViewController.delegate = delegate
        return pinViewController
    }
    
    static func instantiateSetupPinViewController(with delegate: SetupPinDelegate) -> SetupPinViewController {
        let setupPinViewController = Storyboard.numericKeyPad.instantiate(viewController: SetupPinViewController.self)
        setupPinViewController.delegate = delegate
        return setupPinViewController
    }

    static func instantiateTransactionDetailViewController(with viewModel: ViewModel, transactionViewModel: TransactionViewModel) -> UINavigationController {
        let viewController = Storyboard.transactionDetail.initial(viewController: UINavigationController.self)
        if let transactionDetailViewController = viewController.topViewController as? TransactionDetailViewController {
            transactionDetailViewController.transactionViewModel = transactionViewModel
            transactionDetailViewController.viewModel = viewModel
        }
        return viewController
    }

    static func instantiateSendLightningInvoiceViewController(with sendViewModel: SendLightningInvoiceViewModel) -> SendLightningInvoiceViewController {
        let viewController = Storyboard.send.instantiate(viewController: SendLightningInvoiceViewController.self)
        viewController.sendViewModel = sendViewModel
        return viewController
    }

    static func instantiateSendOnChainViewController(with sendOnChainViewModel: SendOnChainViewModel) -> SendOnChainViewController {
        let viewController = Storyboard.sendOnChain.instantiate(viewController: SendOnChainViewController.self)
        viewController.sendOnChainViewModel = sendOnChainViewModel
        return viewController
    }

    static func instantiateTransactionListViewController(with viewModel: ViewModel) -> TransactionListViewController {
        let viewController = Storyboard.transactionList.initial(viewController: TransactionListViewController.self)
        viewController.viewModel = viewModel
        return viewController
    }

    static func instantiateChannelListViewController(with viewModel: ViewModel) -> ChannelListViewController {
        let viewController = Storyboard.channelList.initial(viewController: ChannelListViewController.self)
        viewController.viewModel = viewModel
        return viewController
    }

    static func instantiateConnectRemoteNodeViewController() -> ConnectRemoteNodeViewController {
        return Storyboard.connectRemoteNode.initial(viewController: ConnectRemoteNodeViewController.self)
    }
    
    static func instantiateSettingsContainerViewController(with viewModel: ViewModel) -> UINavigationController {
        let viewController = Storyboard.settings.initial(viewController: UINavigationController.self)
        
        if let settingsContainerViewController = viewController.topViewController as? SettingsContainerViewController {
            settingsContainerViewController.viewModel = viewModel
        }

        return viewController
    }

    static func instantiateMnemonicWordListViewController(with mnemonicWords: [MnemonicWord]) -> MnemonicWordListViewController {
        let viewController = Storyboard.createWallet.instantiate(viewController: MnemonicWordListViewController.self)
        viewController.mnemonicWords = mnemonicWords
        return viewController
    }

    static func instantiateQRCodeDetailViewController(with qrCodeDetailViewModel: QRCodeDetailViewModel) -> QRCodeDetailViewController {
        let viewController = Storyboard.qrCodeDetail.instantiate(viewController: QRCodeDetailViewController.self)
        viewController.viewModel = qrCodeDetailViewModel
        return viewController
    }

    static func instantiateOpenChannelViewController(with openChannelViewModel: OpenChannelViewModel) -> OpenChannelViewController {
        let viewController = Storyboard.openChannel.initial(viewController: OpenChannelViewController.self)
        viewController.openChannelViewModel = openChannelViewModel
        return viewController

    }

    static func instantiateMnemonicViewController() -> MnemonicViewController {
        return Storyboard.createWallet.instantiate(viewController: MnemonicViewController.self)
    }
    
    static func instantiateRecoverWalletViewController() -> RecoverWalletViewController {
        return Storyboard.createWallet.instantiate(viewController: RecoverWalletViewController.self)
    }
    
    static func instantiateDebugViewController() -> UINavigationController {
        return Storyboard.debug.initial(viewController: UINavigationController.self)
    }
}

private enum Storyboard: String {
    case channelList
    case connectRemoteNode
    case createWallet
    case debug
    case deposit
    case invoiceDetail
    case loading
    case main
    case numericKeyPad
    case openChannel
    case paymentDetail
    case qrCodeDetail = "QRCodeDetail"
    case qrCodeScanner = "QRCodeScanner"
    case request
    case send
    case sendOnChain
    case settings
    case sync
    case transactionDetail
    case transactionList
    
    var storyboard: UIStoryboard? {
        let storyboardName = uppercasedStart(rawValue)
        return UIStoryboard(name: storyboardName, bundle: nil)
    }
    
    func instantiate<VC: UIViewController>(viewController: VC.Type) -> VC {
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: storyboardIdentifier(VC.self)) as? VC
            else { fatalError("Couldn't instantiate \(storyboardIdentifier(VC.self)) from \(self.rawValue)") }
        return viewController
    }
    
    func initial<VC: UIViewController>(viewController: VC.Type) -> VC {
        guard let viewController = storyboard?.instantiateInitialViewController() as? VC
            else { fatalError("Couldn't instantiate \(storyboardIdentifier(VC.self)) from \(self.rawValue)") }
        return viewController
    }
    
    private func uppercasedStart(_ string: String) -> String {
        var text = string
        let first = text.remove(at: text.startIndex)
        return "\(first.description.uppercased())\(text)"
    }
    
    private func storyboardIdentifier<VC: UIViewController>(_ viewController: VC.Type) -> String {
        return viewController.description().components(separatedBy: ".").dropFirst().joined(separator: ".")
    }
}
