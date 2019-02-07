//
//  Zap
//
//  Created by Otto Suess on 02.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Lightning
import SafariServices
import UIKit

final class WalletCoordinator: NSObject {
    private let rootViewController: RootViewController
    
    private let lightningService: LightningService
    private let channelListViewModel: ChannelListViewModel
    let historyViewModel: HistoryViewModel
    private let authenticationViewModel: AuthenticationViewModel
    
    private weak var detailViewController: UINavigationController?
    private weak var disconnectWalletDelegate: DisconnectWalletDelegate?
    
    var route: Route?
    
    init(rootViewController: RootViewController, lightningService: LightningService, disconnectWalletDelegate: DisconnectWalletDelegate, authenticationViewModel: AuthenticationViewModel) {
        self.rootViewController = rootViewController
        self.lightningService = lightningService
        self.disconnectWalletDelegate = disconnectWalletDelegate
        self.authenticationViewModel = authenticationViewModel
        
        channelListViewModel = ChannelListViewModel(channelService: lightningService.channelService)
        historyViewModel = HistoryViewModel(historyService: lightningService.historyService)
    }
    
    func start() {
        lightningService.start()
        ExchangeUpdaterJob.start()
        
        updateFor(state: lightningService.connectionService.state.value)
        listenForStateChanges()
    }
    
    func stop() {
        lightningService.stop()
        ExchangeUpdaterJob.stop()
    }
    
    public func listenForStateChanges() {
        lightningService.connectionService.state
            .skip(first: 1)
            .distinct()
            .observeOn(DispatchQueue.main)
            .observeNext { [weak self] state in
                self?.updateFor(state: state)
            }.dispose(in: reactive.bag)
    }
    
    private func updateFor(state: ConnectionStateService.State) {
        print("🗽 state:", state)
        
        switch state {
        case .connecting:
            presentLoading(message: .none)
        case .syncing:
            presentSync()
        case .running:
            presentMain()
        }
    }
    
    private func presentSync() {
        guard let disconnectWalletDelegate = disconnectWalletDelegate else { return }
        let viewController = SyncViewController.instantiate(with: lightningService, delegate: disconnectWalletDelegate)
        presentViewController(viewController)
    }
    
    private func presentLoading(message: LoadingViewController.Message) {
        let viewController = LoadingViewController.instantiate(message: message)
        presentViewController(viewController)
    }
    
    private func presentMain() {
        let tabBarController = RootTabBarController()
        
        tabBarController.viewControllers = [
            walletViewController(),
            historyViewController(),
            settingsViewController()
        ]
        presentViewController(tabBarController)
    
        historyViewModel.setupTabBarBadge(delegate: tabBarController)
        
        if let route = self.route {
            handle(route)
        }
    }
    
    private func presentViewController(_ viewController: UIViewController) {
        rootViewController.setContainerContent(viewController)
    }
    
    func walletViewController() -> WalletViewController {
        return WalletViewController.instantiate(lightningService: lightningService, sendButtonTapped: presentSend, requestButtonTapped: presentRequest)
    }

    func settingsViewController() -> ZapNavigationController {
        guard let disconnectWalletDelegate = disconnectWalletDelegate else { fatalError("Didn't set disconnectWalletDelegate") }
        let settingsViewController = SettingsViewController.instantiate(info: lightningService.infoService.info.value, disconnectWalletDelegate: disconnectWalletDelegate, authenticationViewModel: authenticationViewModel, pushChannelList: pushChannelList, pushNodeURIViewController: pushNodeURIViewController)
        
        let navigationController = ZapNavigationController(rootViewController: settingsViewController)
        
        navigationController.tabBarItem.title = L10n.Scene.Settings.title
        navigationController.tabBarItem.image = Asset.tabbarSettings.image
        navigationController.view.backgroundColor = UIColor.Zap.background

        return navigationController
    }
    
    func historyViewController() -> UINavigationController {
        let viewController = HistoryViewController.instantiate(historyViewModel: historyViewModel, presentFilter: presentFilter, presentDetail: presentDetail, presentSend: presentSend)
        let navigationController = ZapNavigationController(rootViewController: viewController)
        navigationController.tabBarItem.title = L10n.Scene.History.title
        navigationController.tabBarItem.image = Asset.tabbarHistory.image
        
        return navigationController
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
            Toast.presentError(L10n.Error.BlockExplorer.unsupportedNetwork(Settings.shared.blockExplorer.value.localized, lightningService.infoService.network.value.localized))
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
            let viewController = UINavigationController(rootViewController: QRCodeScannerViewController.instantiate(strategy: strategy))
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
        let viewController = UINavigationController(rootViewController: QRCodeScannerViewController.instantiate(strategy: strategy))
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
    
    private func presentFilter() {
        let filterViewController = FilterViewController.instantiate(historyViewModel: historyViewModel)
        let navigationController = ModalNavigationController(rootViewController: filterViewController, height: 480)
        
        navigationController.navigationBar.backgroundColor = UIColor.Zap.seaBlueGradient
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        rootViewController.present(navigationController, animated: true)
    }
    
    private func presentDetail(event: HistoryEventType) {
        let detailViewController = EventDetailViewController(event: event, presentBlockExplorer: presentBlockExplorer)
        rootViewController.present(detailViewController, animated: true)
    }
    
    private func pushChannelList(on navigationController: UINavigationController) {
        let channelList = ChannelListViewController.instantiate(channelListViewModel: channelListViewModel, addChannelButtonTapped: presentAddChannel, presentChannelDetail: presentChannelDetail)
        navigationController.pushViewController(channelList, animated: true)
    }
    
    private func presentChannelDetail(on presentingViewController: UIViewController, channelViewModel: ChannelViewModel) {
        let channelDetailViewController = ChannelDetailViewController(channelViewModel: channelViewModel, channelListViewModel: channelListViewModel, blockExplorerButtonTapped: presentBlockExplorer)
        presentingViewController.present(channelDetailViewController, animated: true, completion: nil)
    }
    
    private func pushNodeURIViewController(on navigationController: UINavigationController) {
        guard
            let info = lightningService.infoService.info.value,
            let qrCodeDetailViewModel = NodeURIQRCodeViewModel(info: info)
            else { return }

        let nodeURIViewController = QRCodeDetailViewController.instantiate(with: qrCodeDetailViewModel)
        navigationController.pushViewController(nodeURIViewController, animated: true)
    }
}

extension WalletCoordinator: Routing {
    public func handle(_ route: Route) {
        if lightningService.connectionService.state.value != .running {
            self.route = route
            return
        }
        
        switch route {
        case .send(let invoice):
            if let invoice = invoice {
                BitcoinInvoiceFactory.create(from: invoice, lightningService: lightningService, completion: { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            self?.presentSend(invoice: invoice)
                        case .failure(let error):
                            Toast.presentError(error.localizedDescription)
                        }
                    }
                })
            } else {
                presentSend(invoice: invoice)
            }
        case .request:
            presentRequest()
        case .connect:
            break // is handled in root coordinator
        }
    }
}
