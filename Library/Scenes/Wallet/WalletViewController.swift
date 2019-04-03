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
import ScrollableGraphView
import SwiftBTC
import SwiftLnd

final class WalletViewController: UIViewController {
    @IBOutlet private weak var graphContainer: UIView!
    @IBOutlet private weak var warningLabel: PaddingLabel! {
        didSet {
            setupPaddingLabel(warningLabel)
            warningLabel.backgroundColor = UIColor.Zap.superRed
            warningLabel.text = L10n.Scene.Wallet.Warning.lndOutdated
        }
    }
    @IBOutlet private weak var networkLabel: PaddingLabel! {
        didSet {
            setupPaddingLabel(networkLabel)
            networkLabel.backgroundColor = UIColor.Zap.invisibleGray
            networkLabel.text = Network.testnet.localized
        }
    }

    @IBOutlet private weak var swapIconImageView: UIImageView! {
        didSet {
            swapIconImageView.tintColor = UIColor.Zap.lightningOrange
        }
    }

    @IBOutlet private weak var primaryBalanceLabel: UILabel!
    @IBOutlet private weak var sendButtonBackground: UIView! {
        didSet {
            sendButtonBackground.backgroundColor = UIColor.Zap.seaBlue
            sendButtonBackground.layer.cornerRadius = 40
            sendButtonBackground.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        }
    }
    @IBOutlet private weak var receiveButtonBackground: UIView! {
        didSet {
            receiveButtonBackground.backgroundColor = UIColor.Zap.seaBlue
            receiveButtonBackground.layer.cornerRadius = 40
            receiveButtonBackground.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        }
    }
    @IBOutlet private weak var secondaryBalanceLabel: UILabel!
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var requestButton: UIButton!
    @IBOutlet private weak var exchangeRateLabel: UILabel!
    @IBOutlet private weak var nodeAliasButton: UIButton!

    // swiftlint:disable implicitly_unwrapped_optional
    private var lightningService: LightningService!
    private var sendButtonTapped: (() -> Void)!
    private var requestButtonTapped: (() -> Void)!
    private var nodeAliasButtonTapped: (() -> Void)!
    // swiftlint:enable implicitly_unwrapped_optional

    private var graphDataSource: GraphViewDataSource?

    static func instantiate(lightningService: LightningService, sendButtonTapped: @escaping () -> Void, requestButtonTapped: @escaping () -> Void, nodeAliasButtonTapped: @escaping () -> Void) -> WalletViewController {
        let walletViewController = StoryboardScene.Wallet.walletViewController.instantiate()
        walletViewController.lightningService = lightningService

        walletViewController.sendButtonTapped = sendButtonTapped
        walletViewController.requestButtonTapped = requestButtonTapped
        walletViewController.nodeAliasButtonTapped = nodeAliasButtonTapped

        walletViewController.tabBarItem.title = L10n.Scene.Wallet.title
        walletViewController.tabBarItem.image = Asset.tabbarWallet.image

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

        Style.Label.body.apply(to: exchangeRateLabel)
        exchangeRateLabel.textColor = UIColor.Zap.gray
        Style.Label.body.apply(to: secondaryBalanceLabel)
        secondaryBalanceLabel.textColor = UIColor.Zap.gray
        secondaryBalanceLabel.textAlignment = .center
        Style.Label.boldTitle.apply(to: primaryBalanceLabel)
        primaryBalanceLabel.textAlignment = .center

        setupGraphView()
        setupExchangeRateLabel()
        setupPrimaryBalanceLabel()
        setupBindings()

//        NotificationCenter.default.addObserver(self, selector: #selector(updateGraphEvents), name: .historyDidChange, object: nil)
    }

    private func setupGraphView() {
        graphContainer.backgroundColor = UIColor.Zap.background
        updateGraphEvents()
    }

    @objc private func updateGraphEvents() {
        guard let historyService = lightningService?.historyService else { return }

        lightningService?.balanceService.total
            .observeNext { [weak self] amount in
                DispatchQueue.main.async {
                    guard let graphContainer = self?.graphContainer else { return }

                    graphContainer.subviews.first?.removeFromSuperview()
                    let graphDataSource = GraphViewDataSource(currentValue: amount, plottableEvents: historyService.userTransaction, currency: Bitcoin.bitcoin)
                    self?.graphDataSource = graphDataSource
                    let graphView = GraphView(frame: graphContainer.bounds, dataSource: graphDataSource)
                    graphContainer.addSubview(graphView)
                }
            }
            .dispose(in: reactive.bag)
    }

    private func setupExchangeRateLabel() {
        Settings.shared.fiatCurrency
            .map { $0.format(satoshis: 100_000_000) }
            .ignoreNil()
            .map(L10n.Scene.Main.exchangeRateLabel)
            .bind(to: exchangeRateLabel.reactive.text)
            .dispose(in: reactive.bag)
    }

    private func setupPrimaryBalanceLabel() {
        if let lightningService = lightningService {
            ReactiveKit
                .combineLatest(lightningService.balanceService.total, Settings.shared.primaryCurrency) { satoshis, currency -> NSAttributedString? in
                    if let bitcoin = currency as? Bitcoin {
                        return bitcoin.attributedFormat(satoshis: satoshis)
                    } else {
                        guard let string = currency.format(satoshis: satoshis) else { return nil }
                        return NSAttributedString(string: string)
                    }
                }
                .bind(to: primaryBalanceLabel.reactive.attributedText)
                .dispose(in: reactive.bag)
        }
    }

    private func setupBindings() {
        lightningService.infoService.info
            .map {
                guard let version = $0?.version else { return true }
                return version.number >= LndConstants.currentVersionNumber
            }
            .bind(to: warningLabel.reactive.isHidden)
            .dispose(in: reactive.bag)

        [
            lightningService?.balanceService.total
                .bind(to: secondaryBalanceLabel.reactive.text, currency: Settings.shared.secondaryCurrency),
            lightningService?.infoService.network
                .map({ $0 == .mainnet }).bind(to: networkLabel.reactive.isHidden),
            lightningService?.infoService.info
                .map({ $0?.alias }).bind(to: nodeAliasButton.reactive.title)
        ].dispose(in: reactive.bag)
    }

    private func setupPaddingLabel(_ paddingLabel: PaddingLabel) {
        paddingLabel.edgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        Style.Label.body.apply(to: paddingLabel)
        paddingLabel.layer.cornerRadius = 10
        paddingLabel.clipsToBounds = true
    }

    @IBAction private func presentSend(_ sender: Any) {
        sendButtonTapped()
    }

    @IBAction private func presentRequest(_ sender: Any) {
        requestButtonTapped()
    }

    @IBAction private func swapCurrencyButtonTapped(_ sender: Any) {
        Settings.shared.swapCurrencies()
    }

    @IBAction private func presentNodeList(_ sender: Any) {
        nodeAliasButtonTapped()
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
