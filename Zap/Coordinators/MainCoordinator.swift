//
//  Zap
//
//  Created by Otto Suess on 02.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class MainCoordinator {
    private let rootViewController: RootViewController
    private let viewModel: ViewModel
    private let channelListViewModel: ChannelListViewModel
    private let transactionListViewModel: TransactionListViewModel
    
    private var mainViewController: MainViewController?
    
    init(rootViewController: RootViewController, viewModel: ViewModel) {
        self.rootViewController = rootViewController
        self.viewModel = viewModel
        
        channelListViewModel = ChannelListViewModel(viewModel: viewModel)
        transactionListViewModel = TransactionListViewModel(viewModel: viewModel)
    }
    
    func start() {
        let viewController = UIStoryboard.instantiateMainViewController(with: viewModel, settingsButtonTapped: presentSettings, sendButtonTapped: presentSend, requestButtonTapped: presentRequest, transactionsButtonTapped: presentTransactions, networkButtonTapped: presentNetwork)
        self.mainViewController = viewController
        DispatchQueue.main.async {
            self.rootViewController.setContainerContent(viewController)
            self.presentTransactions()
        }
    }
    
    private func presentSettings() {
        let viewController = UIStoryboard.instantiateSettingsContainerViewController(with: viewModel)
        mainViewController?.present(viewController, animated: true, completion: nil)
    }
    
    private func presentTransactions() {
        let viewController = UIStoryboard.instantiateTransactionListViewController(with: viewModel, transactionListViewModel: transactionListViewModel, presentTransactionDetail: presentTransactionDetail)
        mainViewController?.setContainerContent(viewController)
    }
    
    private func presentNetwork() {
        let viewController = UIStoryboard.instantiateChannelListViewController(with: viewModel, channelListViewModel: channelListViewModel, presentChannelDetail: presentChannelDetail, addChannelButtonTapped: presentAddChannel)
        mainViewController?.setContainerContent(viewController)
    }
    
    func presentSend() {
        presentSend(invoice: nil)
    }
    
    func presentSend(invoice: String?) {
        let viewController = UIStoryboard.instantiateQRCodeScannerViewController(with: viewModel, strategy: SendQRCodeScannerStrategy())
        mainViewController?.present(viewController, animated: true) {
            if let invoice = invoice,
                let qrCodeScannerViewController = viewController.topViewController as? QRCodeScannerViewController {
                qrCodeScannerViewController.displayViewControllerForAddress(type: .lightningInvoice, address: invoice)
            }
        }
    }
    
    func presentRequest() {
        let viewController = UIStoryboard.instantiateRequestViewController(with: viewModel)
        mainViewController?.present(viewController, animated: true, completion: nil)
    }
    
    private func presentAddChannel() {
        let viewController = UIStoryboard.instantiateQRCodeScannerViewController(with: viewModel, strategy: OpenChannelQRCodeScannerStrategy())
        mainViewController?.present(viewController, animated: true, completion: nil)
    }
    
    private func presentChannelDetail(for channelViewModel: ChannelViewModel) {
        let detailViewModel = ChannelDetailViewModel(channel: channelViewModel.channel)
        let viewController = UIStoryboard.instantiateDetailViewController(with: viewModel, detailViewModel: detailViewModel)
        mainViewController?.present(viewController, animated: true, completion: nil)
    }
    
    private func presentTransactionDetail(for transactionViewModel: TransactionViewModel) {
        let viewController = UIStoryboard.instantiateDetailViewController(with: viewModel, detailViewModel: transactionViewModel.detailViewModel)
        mainViewController?.present(viewController, animated: true, completion: nil)
    }
}
