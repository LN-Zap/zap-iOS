//
//  Zap
//
//  Created by Otto Suess on 02.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Lightning
import SafariServices
import UIKit

final class MainCoordinator: Routing {
    private let rootViewController: RootViewController
    
    private let lightningService: LightningService
    private let channelListViewModel: ChannelListViewModel
    private let transactionListViewModel: TransactionListViewModel
    private let channelTransactionAnnotationUpdater: ChannelTransactionAnnotationUpdater
    
    private weak var detailViewController: UINavigationController?
    private weak var settingsDelegate: SettingsDelegate?
    
    init(rootViewController: RootViewController, lightningService: LightningService, settingsDelegate: SettingsDelegate) {
        self.rootViewController = rootViewController
        self.lightningService = lightningService
        self.settingsDelegate = settingsDelegate
        
        let nodeStore = LightningNodeStore(channelService: lightningService.channelService)
        channelListViewModel = ChannelListViewModel(channelService: lightningService.channelService, nodeStore: nodeStore)
        transactionListViewModel = TransactionListViewModel(transactionService: lightningService.transactionService, nodeStore: nodeStore)
        
        channelTransactionAnnotationUpdater = ChannelTransactionAnnotationUpdater(channelService: lightningService.channelService, transactionService: lightningService.transactionService, updateCallback: transactionListViewModel.updateAnnotationType)
    }
    
    public func handle(_ route: Route) {
        switch route {
        case .send(let invoice):
            if let invoice = invoice,
                let error = SendViewModel(lightningService: lightningService).paymentURI(for: invoice).error as? PaymentURIError {
                rootViewController.presentErrorToast(error.localized)
            } else {
                presentSend(invoice: invoice)
            }
        case .request:
            presentRequest()
        }
    }
    
    func walletViewController() -> UIViewController {
        return UIStoryboard.instantiateWalletViewController(lightningService: lightningService, sendButtonTapped: presentSend, requestButtonTapped: presentRequest)
    }

    func settingsViewController() -> UIViewController {
        guard let settingsDelegate = settingsDelegate else { fatalError("Didn't set settings Delegate") }
        
        return SettingsViewController.instantiate(settingsDelegate: settingsDelegate)
    }
    
    func transactionListViewController() -> UIViewController {
        return UIStoryboard.instantiateTransactionListViewController(transactionListViewModel: transactionListViewModel, presentTransactionDetail: presentTransactionDetail, presentFilter: presentFilter)
    }
    
    func channelListViewController() -> UIViewController {
        return UIStoryboard.instantiateChannelListViewController(channelListViewModel: channelListViewModel, presentChannelDetail: presentChannelDetail, closeButtonTapped: presentMainCloseConfirmation, addChannelButtonTapped: presentAddChannel)
    }
    
    func presentSend() {
        presentSend(invoice: nil)
    }
    
    func presentSend(invoice: String?) {
        let strategy = SendQRCodeScannerStrategy(transactionAnnotationStore: transactionListViewModel.transactionAnnotationStore, nodeStore: channelListViewModel.nodeStore)
        let viewController = UIStoryboard.instantiateQRCodeScannerViewController(with: lightningService, strategy: strategy)
        rootViewController.present(viewController, animated: true) {
            if let invoice = invoice,
                let qrCodeScannerViewController = viewController.topViewController as? QRCodeScannerViewController {
                _ = qrCodeScannerViewController.tryPresentingViewController(for: invoice)
            }
        }
    }
    
    func presentRequest() {
        let viewController = UIStoryboard.instantiateRequestViewController(with: RequestViewModel(transactionService: lightningService.transactionService))
        rootViewController.present(viewController, animated: true, completion: nil)
    }
    
    private func presentAddChannel() {
        let viewController = UIStoryboard.instantiateQRCodeScannerViewController(with: lightningService, strategy: OpenChannelQRCodeScannerStrategy())
        rootViewController.present(viewController, animated: true, completion: nil)
    }
    
    private func presentChannelDetail(for channelViewModel: ChannelViewModel) {
        let detailViewModel = ChannelDetailViewModel(channel: channelViewModel.channel, infoService: lightningService.infoService, channelListViewModel: channelListViewModel)
        presentDetail(for: detailViewModel)
    }
    
    private func presentTransactionDetail(for transactionViewModel: TransactionViewModel) {
        let network = lightningService.infoService.network.value
        presentDetail(for: DetailViewModelFactory.instantiate(from: transactionViewModel, transactionListViewModel: transactionListViewModel, network: network))
    }
    
    private func presentDetail(for detailViewModel: DetailViewModel) {
        let detailViewController = UIStoryboard.instantiateDetailViewController(detailViewModel: detailViewModel, dismissButtonTapped: dismissDetailViewController, safariButtonTapped: presentSafariViewController, closeChannelButtonTapped: presentDetailCloseConfirmation)
        self.detailViewController = detailViewController
        rootViewController.present(detailViewController, animated: true, completion: nil)
    }
    
    private func presentSafariViewController(for url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.preferredBarTintColor = UIColor.zap.charcoalGrey
        safariViewController.preferredControlTintColor = UIColor.zap.peach
        detailViewController?.present(safariViewController, animated: true)
    }
    
    private func dismissDetailViewController() {
        detailViewController?.dismiss(animated: true, completion: nil)
        detailViewController = nil
    }
    
    private func presentMainCloseConfirmation(for channel: Channel, nodeAlias: String, closeAction: @escaping () -> Void) {
        let alertController = UIAlertController.closeChannelAlertController(channel: channel, nodeAlias: nodeAlias, closeAction: closeAction)
        rootViewController.present(alertController, animated: true, completion: nil)
    }
    
    private func presentDetailCloseConfirmation(for channel: Channel, nodeAlias: String, closeAction: @escaping () -> Void) {
        let alertController = UIAlertController.closeChannelAlertController(channel: channel, nodeAlias: nodeAlias, closeAction: closeAction)
        detailViewController?.present(alertController, animated: true, completion: nil)
    }
    
    private func presentFilter() {
        let filterViewController = UIStoryboard.instantiateFilterViewController(transactionListViewModel: transactionListViewModel)
        rootViewController.present(filterViewController, animated: true, completion: nil)
    }
}
