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

extension UIStoryboard {
    static func instantiateWalletViewController(lightningService: LightningService, sendButtonTapped: @escaping () -> Void, requestButtonTapped: @escaping () -> Void) -> WalletViewController {
        
        let walletViewController = Storyboard.wallet.instantiate(viewController: WalletViewController.self)
        walletViewController.lightningService = lightningService
        
        walletViewController.sendButtonTapped = sendButtonTapped
        walletViewController.requestButtonTapped = requestButtonTapped
        
        walletViewController.tabBarItem.title = L10n.Scene.Wallet.title
        walletViewController.tabBarItem.image = Asset.tabbarWallet.image
        
        return walletViewController
    }
}

final class WalletViewController: UIViewController {
    @IBOutlet private weak var graphContainer: UIView!
    @IBOutlet private weak var networkLabel: PaddingLabel! {
        didSet {
            networkLabel.edgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
            Style.Label.body.apply(to: networkLabel)
            networkLabel.layer.cornerRadius = 10
            networkLabel.clipsToBounds = true
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
    
    fileprivate var lightningService: LightningService?
    fileprivate var sendButtonTapped: (() -> Void)?
    fileprivate var requestButtonTapped: (() -> Void)?

    private var graphDataSource: GraphViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.Scene.Wallet.title
        view.backgroundColor = UIColor.Zap.background
        
        Style.Button.custom().apply(to: sendButton, requestButton)

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
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateGraphEvents), name: .historyDidChange, object: nil)
    }
    
    private func setupGraphView() {
        graphContainer.backgroundColor = UIColor.Zap.background
        updateGraphEvents()
    }
    
    @objc private func updateGraphEvents() {
        guard let historyService = lightningService?.historyService else { return }
        
        DispatchQueue.main.async {
            self.graphContainer.subviews.first?.removeFromSuperview()
            let graphDataSource = GraphViewDataSource(currentValue: 88951208, plottableEvents: historyService.userTransaction, currency: Bitcoin(unit: .bitcoin))
            self.graphDataSource = graphDataSource
            let graphView = GraphView(frame: self.graphContainer.bounds, dataSource: graphDataSource)
            self.graphContainer.addSubview(graphView)
        }
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
        [lightningService?.balanceService.total.bind(to: secondaryBalanceLabel.reactive.text, currency: Settings.shared.secondaryCurrency),
         lightningService?.infoService.network.map({ $0 == .mainnet }).bind(to: networkLabel.reactive.isHidden)]
            .dispose(in: reactive.bag)
    }
    
    @IBAction private func presentSend(_ sender: Any) {
        sendButtonTapped?()
    }
    
    @IBAction private func presentRequest(_ sender: Any) {
        requestButtonTapped?()
    }
    
    @IBAction private func swapCurrencyButtonTapped(_ sender: Any) {
        Settings.shared.swapCurrencies()
    }
}

extension Bitcoin {
    public func attributedFormat(satoshis: Satoshi) -> NSAttributedString? {
        let string = satoshis.format(unit: unit)
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.append(NSAttributedString(string: " " + symbol, attributes: [.font: UIFont.Zap.light]))
        return attributedString
    }
}
