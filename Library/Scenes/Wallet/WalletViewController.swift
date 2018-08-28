//
//  Library
//
//  Created by Otto Suess on 25.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation
import Lightning
import ReactiveKit

extension UIStoryboard {
    static func instantiateWalletViewController(lightningService: LightningService, sendButtonTapped: @escaping () -> Void, requestButtonTapped: @escaping () -> Void) -> UINavigationController {
        
        let walletViewController = Storyboard.wallet.instantiate(viewController: WalletViewController.self)
        walletViewController.lightningService = lightningService
        
        walletViewController.sendButtonTapped = sendButtonTapped
        walletViewController.requestButtonTapped = requestButtonTapped
        
        let navigationController = ZapNavigationController(rootViewController: walletViewController)
        navigationController.tabBarItem.title = "scene.wallet.title".localized
        navigationController.tabBarItem.image = UIImage(named: "tabbar_wallet", in: Bundle.library, compatibleWith: nil)
        
        return navigationController
    }
}

final class WalletViewController: UIViewController {
    @IBOutlet private weak var networkLabel: PaddingLabel! {
        didSet {
            networkLabel.edgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
            Style.Label.custom().apply(to: networkLabel)
            networkLabel.layer.cornerRadius = 10
            networkLabel.clipsToBounds = true
            networkLabel.backgroundColor = UIColor.Zap.lightGreen
            networkLabel.text = Network.testnet.localized
        }
    }
    
    @IBOutlet private weak var swapIconImageView: UIImageView! {
        didSet {
            swapIconImageView.tintColor = UIColor.Zap.lightningOrange
        }
    }
    
    @IBOutlet private weak var backgroundGradientView: GradientView! {
        didSet {
            backgroundGradientView.direction = .vertical
            backgroundGradientView.gradient = [UIColor.Zap.seaBlueGradient, UIColor.Zap.seaBlue]
        }
    }
    @IBOutlet private weak var primaryBalanceLabel: UILabel!
    @IBOutlet private weak var sendButtonBackground: UIView! {
        didSet {
            sendButtonBackground.backgroundColor = UIColor.Zap.deepSeaBlue
            sendButtonBackground.layer.cornerRadius = 40
            sendButtonBackground.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        }
    }
    @IBOutlet private weak var receiveButtonBackground: UIView! {
        didSet {
            receiveButtonBackground.backgroundColor = UIColor.Zap.deepSeaBlue
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "scene.wallet.title".localized
        
        Style.Button.custom().apply(to: sendButton, requestButton)

        UIView.performWithoutAnimation {
            sendButton.setTitle("scene.main.send_button".localized, for: .normal)
            sendButton.layoutIfNeeded()
            requestButton.setTitle("scene.main.receive_button".localized, for: .normal)
            requestButton.layoutIfNeeded()
        }
        
        Style.Label.body.apply(to: exchangeRateLabel)
        exchangeRateLabel.textColor = UIColor.Zap.gray
        Style.Label.body.apply(to: secondaryBalanceLabel)
        secondaryBalanceLabel.textColor = UIColor.Zap.gray
        secondaryBalanceLabel.textAlignment = .center
        Style.Label.title.apply(to: primaryBalanceLabel)
        primaryBalanceLabel.textAlignment = .center
        
        Settings.shared.fiatCurrency
            .map { $0.format(satoshis: 100_000_000) }
            .ignoreNil()
            .map { String(format: "scene.main.exchange_rate_label".localized, $0) }
            .bind(to: exchangeRateLabel.reactive.text)
            .dispose(in: reactive.bag)
        
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
