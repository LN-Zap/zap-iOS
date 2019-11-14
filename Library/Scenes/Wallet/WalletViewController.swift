//
//  Library
//
//  Created by Otto Suess on 25.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning
import ReactiveKit
import SwiftBTC
import SwiftLnd

final class WalletViewController: UIViewController {
    // balance detail
    @IBOutlet private weak var balanceDetailView: BalanceDetailView!

    // header
    @IBOutlet private weak var syncView: SyncView!
    @IBOutlet private weak var notificationView: NotificationView!
    
    // send / receive buttons
    @IBOutlet private weak var bottomCurtain: UIView!
    @IBOutlet private weak var buttonContainerView: UIView!
    @IBOutlet private weak var sendButtonBackground: UIView!
    @IBOutlet private weak var receiveButtonBackground: UIView!
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var requestButton: UIButton!

    // balance view
    @IBOutlet private weak var totalBalanceLabel: UILabel!
    @IBOutlet private weak var swapIconImageView: UIImageView!
    @IBOutlet private weak var primaryBalanceLabel: UILabel!
    @IBOutlet private weak var secondaryBalanceLabel: UILabel!

    // swiftlint:disable implicitly_unwrapped_optional
    private var walletViewModel: WalletViewModel!
    private var sendButtonTapped: (() -> Void)!
    private var requestButtonTapped: (() -> Void)!
    private var historyButtonTapped: (() -> Void)!
    private var nodeButtonTapped: (() -> Void)!
    private var channelButtonTapped: (() -> Void)!
    private var emptyStateViewModel: WalletEmptyStateViewModel!
    // swiftlint:enable implicitly_unwrapped_optional
    
    // swiftlint:disable:next function_parameter_count
    static func instantiate(
        walletViewModel: WalletViewModel,
        sendButtonTapped: @escaping () -> Void,
        requestButtonTapped: @escaping () -> Void,
        historyButtonTapped: @escaping () -> Void,
        nodeButtonTapped: @escaping () -> Void,
        channelButtonTapped: @escaping () -> Void,
        emptyStateViewModel: WalletEmptyStateViewModel
    ) -> WalletViewController {
        let walletViewController = StoryboardScene.Wallet.walletViewController.instantiate()
        walletViewController.walletViewModel = walletViewModel

        walletViewController.sendButtonTapped = sendButtonTapped
        walletViewController.requestButtonTapped = requestButtonTapped
        walletViewController.emptyStateViewModel = emptyStateViewModel
        walletViewController.historyButtonTapped = historyButtonTapped
        walletViewController.nodeButtonTapped = nodeButtonTapped
        walletViewController.channelButtonTapped = channelButtonTapped

        return walletViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.Scene.Wallet.title
        view.backgroundColor = UIColor.Zap.background

        Style.Button.custom().apply(to: sendButton, requestButton)

        requestButton.accessibilityIdentifier = "Request"
        UIView.performWithoutAnimation {
            sendButton.setTitle(L10n.Scene.Main.sendButton, for: .normal)
            sendButton.layoutIfNeeded()
            requestButton.setTitle(L10n.Scene.Main.receiveButton, for: .normal)
            requestButton.layoutIfNeeded()
        }

        Style.Label.body.apply(to: secondaryBalanceLabel, totalBalanceLabel)
        totalBalanceLabel.text = L10n.Scene.Wallet.totalBalance
        secondaryBalanceLabel.textColor = UIColor.Zap.gray
        secondaryBalanceLabel.textAlignment = .center
        Style.Label.boldTitle.apply(to: primaryBalanceLabel)
        primaryBalanceLabel.textAlignment = .center

        bottomCurtain.backgroundColor = UIColor.Zap.deepSeaBlue

        buttonContainerView.layer.cornerRadius = Constants.buttonCornerRadius
        buttonContainerView.clipsToBounds = true
        buttonContainerView.backgroundColor = UIColor.Zap.deepSeaBlue

        sendButtonBackground.backgroundColor = UIColor.Zap.seaBlue
        receiveButtonBackground.backgroundColor = UIColor.Zap.seaBlue

        swapIconImageView.tintColor = UIColor.Zap.lightningOrange

        setupPrimaryBalanceLabel()
        setupBindings()

        balanceDetailView.setup(viewModel: walletViewModel.balanceDetailViewModel)
        setupEmtpyState()

        syncView.syncViewModel = walletViewModel.syncViewModel
        syncView.isHidden = true
        
        setupChannelNotification()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        balanceDetailView.updatePosition()
    }
    
    private func setupChannelNotification() {
        notificationView.isHidden = true
                
        notificationView.notificationViewModel = NotificationViewModel(message: L10n.Scene.Wallet.OpenChannel.message, actionTitle: L10n.Scene.Wallet.OpenChannel.action) { [weak self] in
            self?.walletViewModel.didDismissChannelEmptyState.value = true
            self?.channelButtonTapped()
        }
        
        walletViewModel.shouldHideChannelEmptyState
            .observeOn(DispatchQueue.main)
            .observeNext { [weak self] isHidden in
                UIView.animate(withDuration: 0.3) {
                    self?.notificationView.isHidden = isHidden
                    self?.notificationView.alpha = isHidden  ? 0 : 1
                }
            }
            .dispose(in: reactive.bag)
    }

    private func setupEmtpyState() {
        let emptyStateView = EmptyStateView(viewModel: emptyStateViewModel)
        emptyStateView.add(to: view)

        walletViewModel.shouldHideEmptyWalletState
            .bind(to: emptyStateView.reactive.isHidden)
            .dispose(in: reactive.bag)
    }

    private func setupPrimaryBalanceLabel() {
        ReactiveKit
            .combineLatest(walletViewModel.lightningService.balanceService.totalBalance, Settings.shared.primaryCurrency) { satoshis, currency -> NSAttributedString? in
                if let bitcoin = currency as? Bitcoin {
                    return bitcoin.attributedFormat(satoshis: satoshis)
                } else {
                    guard let string = currency.format(satoshis: satoshis) else { return nil }
                    return NSAttributedString(string: string)
                }
            }
            .distinctUntilChanged()
            .bind(to: primaryBalanceLabel.reactive.attributedText)
            .dispose(in: reactive.bag)
    }

    private func setupBindings() {
        walletViewModel.lightningService.balanceService.totalBalance
            .distinctUntilChanged()
            .bind(to: secondaryBalanceLabel.reactive.text, currency: Settings.shared.secondaryCurrency)
            .dispose(in: reactive.bag)
    }

    @IBAction private func presentSend(_ sender: Any) {
        sendButtonTapped()
    }

    @IBAction private func presentRequest(_ sender: Any) {
        requestButtonTapped()
    }

    @IBAction private func presentHistory(_ sender: UIButton) {
        historyButtonTapped()
    }

    @IBAction private func presentSettings(_ sender: UIButton) {
        nodeButtonTapped()
    }

    @IBAction private func swapCurrencyButtonTapped(_ sender: Any) {
        Settings.shared.swapCurrencies()
    }
}

private extension Bitcoin {
    func attributedFormat(satoshis: Satoshi) -> NSAttributedString? {
        let formatter = SatoshiFormatter(unit: self)
        formatter.includeCurrencySymbol = false
        let amountString = formatter.string(from: satoshis) ?? "0"
        let attributedString = NSMutableAttributedString(string: amountString)
        attributedString.append(NSAttributedString(string: " " + symbol, attributes: [.font: UIFont.Zap.light]))
        return attributedString
    }
}
