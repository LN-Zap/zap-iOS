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
    
    private var mainViewController: MainViewController?
    
    init(rootViewController: RootViewController, viewModel: ViewModel) {
        self.rootViewController = rootViewController
        self.viewModel = viewModel
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
        let viewController = UIStoryboard.instantiateTransactionListViewController(with: viewModel, presentTransactionDetail: presentTransactionDetail)
        mainViewController?.setContainerContent(viewController)
    }
    
    private func presentNetwork() {
        let viewController = UIStoryboard.instantiateChannelListViewController(with: viewModel, presentChannelDetail: presentChannelDetail, addChannelButtonTapped: presentAddChannel)
        mainViewController?.setContainerContent(viewController)
    }
    
    private func presentSend() {
        let viewController = UIStoryboard.instantiateQRCodeScannerViewController(with: viewModel, strategy: SendQRCodeScannerStrategy())
        mainViewController?.present(viewController, animated: true, completion: nil)
    }
    
    private func presentRequest() {
        let viewController = UIStoryboard.instantiateRequestViewController(with: viewModel)
        mainViewController?.present(viewController, animated: true, completion: nil)
    }
    
    private func presentAddChannel() {
        let viewController = UIStoryboard.instantiateQRCodeScannerViewController(with: viewModel, strategy: OpenChannelQRCodeScannerStrategy())
        mainViewController?.present(viewController, animated: true, completion: nil)
    }
    
    private func presentChannelDetail(for channelViewModel: ChannelViewModel) {
        let viewController = UIStoryboard.instantiateChannelDetailViewController(with: viewModel, channelViewModel: channelViewModel)
        mainViewController?.present(viewController, animated: true, completion: nil)
    }
    
    private func presentTransactionDetail(for transactionViewModel: TransactionViewModel) {
        let viewController = UIStoryboard.instantiateTransactionDetailViewController(with: viewModel, transactionViewModel: transactionViewModel)
        mainViewController?.present(viewController, animated: true, completion: nil)
    }
}
