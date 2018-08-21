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
            if let invoice = invoice {
                Invoice.create(from: invoice, lightningService: lightningService, callback: { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            self?.presentSend(invoice: invoice)
                        case .failure(let error):
                            guard let localizedError = error as? Localizable else { break }
                            self?.rootViewController.presentErrorToast(localizedError.localized)
                        }
                    }
                })
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
        return UIStoryboard.instantiateChannelListViewController(channelListViewModel: channelListViewModel, closeButtonTapped: presentCloseConfirmation, addChannelButtonTapped: presentAddChannel, blockExplorerButtonTapped: presentBlockExplorer)
    }
    
    func presentSend() {
        presentSend(invoice: nil)
    }
    
    func presentBlockExplorer(code: String, type: BlockExplorer.CodeType) {
        let network = lightningService.infoService.network.value
        do {
            guard let url = try Settings.shared.blockExplorer.value.url(network: network, code: code, type: type) else { return }
            presentSafariViewController(for: url)
        } catch BlockExplorerError.unsupportedNetwork {
            (detailViewController ?? rootViewController).presentErrorToast(String(format: "error.block_explorer.unsupported_network".localized, Settings.shared.blockExplorer.value.localized, lightningService.infoService.network.value.localized))
        } catch {
            print("Unexpected error: \(error).")
        }
    }
    
    func presentSend(invoice: String?) {
        let strategy = SendQRCodeScannerStrategy(transactionAnnotationStore: transactionListViewModel.transactionAnnotationStore, nodeStore: channelListViewModel.nodeStore, lightningService: lightningService)
        let viewController = UIStoryboard.instantiateQRCodeScannerViewController(strategy: strategy)
        rootViewController.present(viewController, animated: true) {
            if let invoice = invoice,
                let qrCodeScannerViewController = viewController.topViewController as? QRCodeScannerViewController {
                _ = qrCodeScannerViewController.tryPresentingViewController(for: invoice)
            }
        }
    }
    
    func presentRequest() {
        let viewModel = RequestViewModel(transactionService: lightningService.transactionService)
        let viewController = RequestModalDetailViewController(viewModel: viewModel)
        rootViewController.present(viewController, animated: true, completion: nil)
    }
    
    private func presentAddChannel() {
        let strategy = OpenChannelQRCodeScannerStrategy(lightningService: lightningService)
        let viewController = UIStoryboard.instantiateQRCodeScannerViewController(strategy: strategy)
        rootViewController.present(viewController, animated: true, completion: nil)
    }
    
    private func presentTransactionDetail(for transactionViewModel: TransactionViewModel) {
        let detailViewModel = DetailViewModelFactory.instantiate(from: transactionViewModel, transactionListViewModel: transactionListViewModel)
        let detailViewController = UIStoryboard.instantiateDetailViewController(detailViewModel: detailViewModel, dismissButtonTapped: dismissDetailViewController, blockExplorerButtonTapped: presentBlockExplorer)
        self.detailViewController = detailViewController
        rootViewController.present(detailViewController, animated: true, completion: nil)
    }
    
    private func presentSafariViewController(for url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.preferredBarTintColor = UIColor.Zap.deepSeaBlue
        safariViewController.preferredControlTintColor = UIColor.Zap.lightningOrange
        (detailViewController ?? rootViewController).present(safariViewController, animated: true)
    }
    
    private func dismissDetailViewController() {
        detailViewController?.dismiss(animated: true, completion: nil)
        detailViewController = nil
    }
    
    private func presentCloseConfirmation(for channelViewModel: ChannelViewModel, closeAction: @escaping () -> Void) {
        let alertController = UIAlertController.closeChannelAlertController(channelViewModel: channelViewModel, closeAction: closeAction)
        rootViewController.present(alertController, animated: true, completion: nil)
    }
    
    private func presentFilter() {
        let filterViewController = UIStoryboard.instantiateFilterViewController(transactionListViewModel: transactionListViewModel)
        rootViewController.present(filterViewController, animated: true, completion: nil)
    }
}
