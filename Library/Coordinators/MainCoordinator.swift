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
    let historyViewModel: HistoryViewModel
    private let authenticationViewModel: AuthenticationViewModel
    
    private weak var detailViewController: UINavigationController?
    private weak var settingsDelegate: SettingsDelegate?
    
    init(rootViewController: RootViewController, lightningService: LightningService, settingsDelegate: SettingsDelegate, authenticationViewModel: AuthenticationViewModel) {
        self.rootViewController = rootViewController
        self.lightningService = lightningService
        self.settingsDelegate = settingsDelegate
        self.authenticationViewModel = authenticationViewModel
        
        channelListViewModel = ChannelListViewModel(channelService: lightningService.channelService)
        historyViewModel = HistoryViewModel(historyService: lightningService.historyService)
    }
    
    public func handle(_ route: Route) {
        switch route {
        case .send(let invoice):
            if let invoice = invoice {
                BitcoinInvoiceFactory.create(from: invoice, lightningService: lightningService, completion: { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            self?.presentSend(invoice: invoice)
                        case .failure(let error):
                            self?.rootViewController.presentErrorToast(error.localizedDescription)
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
        
        return SettingsViewController.instantiate(settingsDelegate: settingsDelegate, pushChannelList: pushChannelList)
    }
    
    func historyViewController() -> UIViewController {
        return UIStoryboard.instantiateHistoryViewController(historyViewModel: historyViewModel, presentFilter: presentFilter, presentDetail: presentDetail, presentSend: presentSend)
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
        let strategy = SendQRCodeScannerStrategy(lightningService: lightningService, authenticationViewModel: authenticationViewModel)
        
        if let invoice = invoice {
            DispatchQueue(label: "presentSend").async {
                let group = DispatchGroup()
                group.enter()
                strategy.viewControllerForAddress(address: invoice) { [weak self] result in
                    group.leave()
                    guard let viewController = result.value else { return }
                    self?.rootViewController.present(viewController, animated: true)
                }
                group.wait()
            }
        } else {
            let viewController = UIStoryboard.instantiateQRCodeScannerViewController(strategy: strategy)
            rootViewController.present(viewController, animated: true)
        }
    }
    
    func presentRequest() {
        let viewModel = RequestViewModel(transactionService: lightningService.transactionService)
        let viewController = RequestViewController(viewModel: viewModel)
        rootViewController.present(viewController, animated: true)
    }
    
    private func presentAddChannel() {
        let strategy = OpenChannelQRCodeScannerStrategy(lightningService: lightningService)
        let viewController = UIStoryboard.instantiateQRCodeScannerViewController(strategy: strategy)
        rootViewController.present(viewController, animated: true)
    }
    
    private func presentSafariViewController(for url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.preferredBarTintColor = UIColor.Zap.deepSeaBlue
        safariViewController.preferredControlTintColor = UIColor.Zap.lightningOrange
        (detailViewController ?? rootViewController).present(safariViewController, animated: true)
    }
    
    private func dismissDetailViewController() {
        detailViewController?.dismiss(animated: true)
        detailViewController = nil
    }
    
    private func presentCloseConfirmation(for channelViewModel: ChannelViewModel, closeAction: @escaping () -> Void) {
        let alertController = UIAlertController.closeChannelAlertController(channelViewModel: channelViewModel, closeAction: closeAction)
        rootViewController.present(alertController, animated: true)
    }
    
    private func presentFilter() {
        let filterViewController = UIStoryboard.instantiateFilterViewController(historyViewModel: historyViewModel)
        rootViewController.present(filterViewController, animated: true)
    }
    
    private func presentDetail(event: HistoryEventType) {
        let detailViewController = EventDetailViewController(event: event, presentBlockExplorer: presentBlockExplorer)
        rootViewController.present(detailViewController, animated: true)
    }
    
    private func pushChannelList(on navigationController: UINavigationController) {
        let channelList = UIStoryboard.instantiateChannelListViewController(channelListViewModel: channelListViewModel, closeButtonTapped: presentCloseConfirmation, addChannelButtonTapped: presentAddChannel, blockExplorerButtonTapped: presentBlockExplorer)
        navigationController.pushViewController(channelList, animated: true)
    }
}
