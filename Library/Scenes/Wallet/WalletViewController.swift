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

extension UIStoryboard {
    static func instantiateWalletViewController(lightningService: LightningService, sendButtonTapped: @escaping () -> Void, requestButtonTapped: @escaping () -> Void) -> UINavigationController {
        
        let walletViewController = Storyboard.wallet.instantiate(viewController: WalletViewController.self)
        walletViewController.lightningService = lightningService
        
        walletViewController.sendButtonTapped = sendButtonTapped
        walletViewController.requestButtonTapped = requestButtonTapped
        
        let navigationController = ZapNavigationController(rootViewController: walletViewController)
        navigationController.tabBarItem.title = "Wallet"
        navigationController.tabBarItem.image = UIImage(named: "tabbar_wallet", in: Bundle.library, compatibleWith: nil)
        
        return navigationController
    }
}

final class WalletViewController: UIViewController {
    @IBOutlet private weak var backgroundGradientView: GradientView! {
        didSet {
            backgroundGradientView.direction = .vertical
            backgroundGradientView.gradient = [UIColor.zap.seaBlue, UIColor.zap.seaBlueGradient]
        }
    }
    @IBOutlet private weak var primaryBalanceLabel: UILabel!
    @IBOutlet private weak var sendButtonBackground: UIView! {
        didSet {
            sendButtonBackground.backgroundColor = UIColor.zap.deepSeaBlue
            sendButtonBackground.layer.cornerRadius = 40
            sendButtonBackground.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        }
    }
    @IBOutlet private weak var receiveButtonBackground: UIView! {
        didSet {
            receiveButtonBackground.backgroundColor = UIColor.zap.deepSeaBlue
            receiveButtonBackground.layer.cornerRadius = 40
            receiveButtonBackground.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        }
    }
    @IBOutlet private weak var secondaryBalanceLabel: UILabel!
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var requestButton: UIButton!

    fileprivate var lightningService: LightningService?
    fileprivate var sendButtonTapped: (() -> Void)?
    fileprivate var requestButtonTapped: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Wallet"
        
        Style.button.apply(to: sendButton, requestButton)

        UIView.performWithoutAnimation {
            sendButton.setTitle("scene.main.send_button".localized, for: .normal)
            sendButton.layoutIfNeeded()
            requestButton.setTitle("scene.main.receive_button".localized, for: .normal)
            requestButton.layoutIfNeeded()
        }
        
        Style.label.apply(to: secondaryBalanceLabel)
        primaryBalanceLabel.textColor = .white
        primaryBalanceLabel.font = primaryBalanceLabel.font.withSize(40)
        secondaryBalanceLabel.textColor = .gray

        [lightningService?.balanceService.total.bind(to: primaryBalanceLabel.reactive.text, currency: Settings.shared.primaryCurrency),
         lightningService?.balanceService.total.bind(to: secondaryBalanceLabel.reactive.text, currency: Settings.shared.secondaryCurrency)]
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
