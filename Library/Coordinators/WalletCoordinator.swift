//
//  Zap
//
//  Created by Otto Suess on 02.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Lightning
import Logger
import SafariServices
import SwiftBTC
import UIKit

// swiftlint:disable type_body_length file_length
final class WalletCoordinator: NSObject, Coordinator {
    let rootViewController: RootViewController

    private let lightningService: LightningService
    private let channelListViewModel: ChannelListViewModel
    let historyViewModel: HistoryViewModel
    private let authenticationViewModel: AuthenticationViewModel
    private let walletConfigurationStore: WalletConfigurationStore

    private weak var detailViewController: UINavigationController?
    private weak var channelListViewController: UIViewController?
    private weak var disconnectWalletDelegate: WalletDelegate?

    private var notificationScheduler: NotificationScheduler?
    private var currentState: InfoService.WalletState

    private var pageViewController: WalletPageViewController?
    
    var route: Route?

    init(rootViewController: RootViewController, lightningService: LightningService, disconnectWalletDelegate: WalletDelegate, authenticationViewModel: AuthenticationViewModel, walletConfigurationStore: WalletConfigurationStore) {
        self.rootViewController = rootViewController
        self.lightningService = lightningService
        self.disconnectWalletDelegate = disconnectWalletDelegate
        self.authenticationViewModel = authenticationViewModel
        self.walletConfigurationStore = walletConfigurationStore

        self.channelListViewModel = ChannelListViewModel(lightningService: lightningService)
        self.historyViewModel = HistoryViewModel(historyService: lightningService.historyService)
        self.currentState = lightningService.infoService.walletState.value

        super.init()
        listenForStateChanges()
    }

    func start() {
        if lightningService.connection == .local {
            lightningService.startLocalWallet(network: BuildConfiguration.network, password: Password.get()) {
                if case .failure(let error) = $0 {
                    DispatchQueue.main.async {
                        Toast.presentError(error.localizedDescription)
                    }
                }
            }

            // Schedule sync reminder notifications
            notificationScheduler = NotificationScheduler(configurations: [
                NotificationScheduler.Configuration(daysLeft: 2, title: L10n.Notification.Sync.title, body: L10n.Notification.Sync.Day12.body),
                NotificationScheduler.Configuration(daysLeft: 1, title: L10n.Notification.Sync.title, body: L10n.Notification.Sync.Day13.body),
                NotificationScheduler.Configuration(daysLeft: 0, title: L10n.Notification.Sync.title, body: L10n.Notification.Sync.Day14.body)
            ])
            notificationScheduler?.listenToChannelUpdates(lightningService: lightningService)
        }

        lightningService.start()
        ExchangeUpdaterJob.start()
        updateFor(state: lightningService.infoService.walletState.value)
    }

    func stop() {
        lightningService.stop()
        ExchangeUpdaterJob.stop()
    }

    public func listenForStateChanges() {
        lightningService.infoService.walletState
            .dropFirst(1)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .observeNext { [weak self] state in
                self?.updateFor(state: state)
            }.dispose(in: reactive.bag)
    }

    private func updateFor(state: InfoService.WalletState) {
        Logger.info("state: \(state)", customPrefix: "🗽")

        switch state {
        case .connecting:
            presentLoading()
        case .running, .syncing:
            if currentState != .syncing && currentState != .running {
                presentMain()
            }
        case .locked:
            presentUnlockWallet()
        case .error:
            disconnectWalletDelegate?.disconnect()
        }
        
        self.currentState = state

        UIApplication.shared.isIdleTimerDisabled = lightningService.connection == .local && state == .syncing
    }

    private func presentUnlockWallet() {
        guard
            case .remote(let rpcConfiguration) = lightningService.connection, // we can only unlock remote nodes
            let disconnectWalletDelegate = disconnectWalletDelegate
            else { return }

        let unlockWalletViewModel = UnlockWalletViewModel(lightningService: lightningService, alias: rpcConfiguration.host.absoluteString)
        let viewController = UnlockWalletViewController.instantiate(unlockWalletViewModel: unlockWalletViewModel, disconnectWalletDelegate: disconnectWalletDelegate)
        let navigationController = ZapNavigationController(rootViewController: viewController)
        presentViewController(navigationController)
    }

    private func presentLoading() {
        let viewController = LoadingViewController.instantiate()
        presentViewController(viewController)
    }

    private func presentMain() {
        guard rootViewController.currentViewController != pageViewController else { return }

        let pageViewController = WalletPageViewController.instantiate(walletViewController: walletViewController(), nodeViewController: nodeViewController, historyViewController: historyViewController)
        presentViewController(pageViewController)
        
        self.pageViewController = pageViewController

        if let route = self.route {
            handle(route)
        }
    }

    private func presentViewController(_ viewController: UIViewController) {
        rootViewController.setContainerContent(viewController)
    }

    func walletViewController() -> WalletViewController {
        let walletViewModel = WalletViewModel(lightningService: lightningService)
        let walletEmptyStateViewModel = WalletEmptyStateViewModel(lightningService: lightningService, fundButtonTapped: presentFundWallet)
        return WalletViewController.instantiate(
            walletViewModel: walletViewModel,
            sendButtonTapped: presentSend,
            requestButtonTapped: presentRequest,
            historyButtonTapped: presentHistory,
            nodeButtonTapped: presentNode,
            channelButtonTapped: presentChannelList,
            emptyStateViewModel: walletEmptyStateViewModel
        )
    }

    private func disconnectWallet() {
        disconnectWalletDelegate?.disconnect()
    }
    
    private func presentHistory() {
        pageViewController?.presentHistory()
    }

    private func presentNode() {
        pageViewController?.presentNode()
    }

    private func presentWallet() {
        pageViewController?.presentWallet()
    }
    
    private func nodeViewController() -> ZapNavigationController {
        let navigationController = ZapNavigationController()

        let nodeViewController = NodeViewController.instantiate(
            lightningService: lightningService,
            presentChannels: pushChannelList(on: navigationController),
            presentSettings: pushSettings(on: navigationController),
            presentWallet: presentWallet,
            manageNodes: presentWalletList,
            presentChannelBackup: presentChannelBackup(on: navigationController),
            presentURIViewController: pushNodeURIViewController
        )
        
        navigationController.viewControllers = [nodeViewController]
        return navigationController
    }

    private func pushSettings(on navigationController: UINavigationController) -> (() -> Void) {
        return { [weak self] in
            guard let viewController = self?.settingsViewController() else { return }
            navigationController.pushViewController(viewController, animated: true)
        }
    }

    func settingsViewController() -> SettingsViewController {
        return SettingsViewController(
            info: lightningService.infoService.info.value,
            connection: lightningService.connection,
            authenticationViewModel: authenticationViewModel,
            pushLndLogViewController: pushLndLogViewController
        )
    }

    func historyViewController() -> UINavigationController {
        let viewController = HistoryViewController.instantiate(
            historyViewModel: historyViewModel,
            presentFilter: presentFilter,
            presentDetail: presentDetail,
            presentSend: presentSend,
            presentWallet: presentWallet
        )
        let navigationController = ZapNavigationController(rootViewController: viewController)

        return navigationController
    }

    func presentSend() {
        presentSend(invoice: nil)
    }

    func presentBlockExplorer(code: String, type: BlockExplorer.CodeType) {
        guard let network = lightningService.infoService.network.value else { return }
        do {
            guard let url = try Settings.shared.blockExplorer.value.url(network: network, code: code, type: type) else { return }
            presentSafariViewController(for: url)
        } catch BlockExplorerError.unsupportedNetwork {
            Toast.presentError(L10n.Error.BlockExplorer.unsupportedNetwork(Settings.shared.blockExplorer.value.localized, network.localized))
        } catch {
            Logger.error("Unexpected error: \(error).")
        }
    }

    /// Presented from the empty state of the wallet scene.
    ///
    /// - Parameter uri: The bitcoin uri the funds should be sent to.
    func presentFundWallet(uri: BitcoinURI) {
        let viewModel = RequestQRCodeViewModel(paymentURI: uri)
        let viewController = QRCodeDetailViewController.instantiate(with: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        rootViewController.present(navigationController, animated: true)
    }

    func presentSend(invoice: String?) {
        let strategy = CombinedQRCodeScannetStrategy(strategies: [
            SendQRCodeScannerStrategy(lightningService: lightningService, authenticationViewModel: authenticationViewModel),
            LNURLWithdrawQRCodeScannetStrategy(lightningService: lightningService)
        ])
        
        if let invoice = invoice {
            DispatchQueue(label: "presentSend").async {
                let group = DispatchGroup()
                group.enter()
                strategy.viewControllerForAddress(address: invoice) { [weak self] result in
                    group.leave()
                    guard let viewController = try? result.get() else { return }
                    self?.rootViewController.present(viewController, animated: true)
                }
                group.wait()
            }
        } else {
            let viewController = UINavigationController(rootViewController: QRCodeScannerViewController(strategy: strategy))
            viewController.modalPresentationStyle = .fullScreen
            rootViewController.present(viewController, animated: true)
        }
    }

    func presentLNURLWithdrawQRCodeScanner() {
        let strategy = LNURLWithdrawQRCodeScannetStrategy(lightningService: lightningService)
        let viewController = UINavigationController(rootViewController: QRCodeScannerViewController(strategy: strategy))
        viewController.modalPresentationStyle = .fullScreen
        rootViewController.present(viewController, animated: true)
    }
    
    func presentRequest() {
        let viewModel = RequestViewModel(lightningService: lightningService)
        let viewController = RequestViewController(viewModel: viewModel, presentQrCode: presentLNURLWithdrawQRCodeScanner)
        rootViewController.present(viewController, animated: true)
    }

    private func presentWalletList() {
        guard let disconnectWalletDelegate = disconnectWalletDelegate else { return }

        UISelectionFeedbackGenerator().selectionChanged()
        let viewController = WalletListViewController.instantiate(walletConfigurationStore: walletConfigurationStore, disconnectWalletDelegate: disconnectWalletDelegate)
        let navigationController = UINavigationController(rootViewController: viewController)
        rootViewController.present(navigationController, animated: true)
    }
    
    private func presentAddChannel() {
        let strategy = OpenChannelQRCodeScannerStrategy(lightningService: lightningService)
        let viewController = UINavigationController(rootViewController: ChannelQRCodeScannerViewController(strategy: strategy, network: lightningService.infoService.network.value))
        viewController.modalPresentationStyle = .fullScreen
        channelListViewController?.present(viewController, animated: true)
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
        let navigationController = UINavigationController(rootViewController: filterViewController)

        navigationController.navigationBar.backgroundColor = UIColor.Zap.seaBlueGradient
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)

        rootViewController.present(navigationController, animated: true)
    }

    private func presentDetail(event: HistoryEventType) {
        let detailViewController = EventDetailViewController(event: event, presentBlockExplorer: presentBlockExplorer)
        rootViewController.present(detailViewController, animated: true)
    }

    private func channelList() -> ChannelListViewController {
        let walletEmptyStateViewModel = WalletEmptyStateViewModel(lightningService: lightningService, fundButtonTapped: presentFundWallet)
        let channelListEmptyStateViewModel = ChannelListEmptyStateViewModel(openButtonTapped: presentAddChannel)
        let viewController = ChannelListViewController.instantiate(
            channelListViewModel: channelListViewModel,
            addChannelButtonTapped: presentAddChannel,
            presentChannelDetail: presentChannelDetail,
            walletEmptyStateViewModel: walletEmptyStateViewModel,
            channelListEmptyStateViewModel: channelListEmptyStateViewModel)
        
        channelListViewController = viewController
        return viewController
    }
    
    private func pushChannelList(on navigationController: UINavigationController) -> (() -> Void) {
        return { [weak self] in
            guard let self = self else { return }
            navigationController.pushViewController(self.channelList(), animated: true)
        }
    }
    
    private func presentChannelList() {
        let navigationController = ZapNavigationController(rootViewController: channelList())
        rootViewController.present(navigationController, animated: true)
    }

    private func presentChannelBackup(on navigationController: UINavigationController) -> (() -> Void) {
        return { [weak self] in
            guard let nodePubKey = self?.walletConfigurationStore.selectedWallet?.nodePubKey else { return }
            let viewController = ChannelBackupViewController.instantiate(nodePubKey: nodePubKey)
            navigationController.pushViewController(viewController, animated: true)
        }
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

    private func pushLndLogViewController(on navigationController: UINavigationController) {
        let viewController = LndLogViewController.instantiate(network: BuildConfiguration.network)
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension WalletCoordinator: Routing {
    public func handle(_ route: Route) {
        if lightningService.infoService.walletState.value != .running {
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
