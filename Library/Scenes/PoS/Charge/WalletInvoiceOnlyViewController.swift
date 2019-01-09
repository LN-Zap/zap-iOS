//
//  Library
//
//  Created by Otto Suess on 02.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import Lightning
import SwiftBTC

extension UIStoryboard {
    static func instantiateWalletInvoiceOnlyViewController(lightningService: LightningService) -> WalletInvoiceOnlyViewController {
        let walletViewController = StoryboardScene.WalletInvoiceOnly.walletInvoiceOnlyViewController.instantiate()
        walletViewController.lightningService = lightningService
        
        walletViewController.tabBarItem.title = L10n.Scene.Wallet.title
        walletViewController.tabBarItem.image = Asset.tabbarWallet.image
        
        return walletViewController
    }
}

final class WalletInvoiceOnlyViewController: UIViewController {
    @IBOutlet private weak var createInvoiceButton: UIButton!
    @IBOutlet private weak var keyPadView: KeyPadView! {
        didSet {
            setupKeyPad()
        }
    }
    @IBOutlet private weak var primaryCurrencyLabel: UILabel!
    @IBOutlet private weak var secondaryCurrencyLabel: UILabel!

    fileprivate var lightningService: LightningService?
    
    private var satoshis: Satoshi = 0 {
        didSet {
            createInvoiceButton.isEnabled = satoshis > 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.Zap.background
        
        Style.Label.headline.apply(to: primaryCurrencyLabel)
        Style.Label.subHeadline.apply(to: secondaryCurrencyLabel)
        
        Style.Button.background.apply(to: createInvoiceButton)
        
        createInvoiceButton.setTitle("Next", for: .normal)
        createInvoiceButton.isEnabled = false
        
        _ = updateKeyPadString(input: "")
    }
    
    private func setupKeyPad() {
        keyPadView.handler = { [weak self] in
            self?.updateKeyPadString(input: $0) ?? false
        }
    }
    
    private func updateKeyPadString(input: String) -> Bool {
        guard input.count <= 16 else { return false }
        
        let numberFormatter = InputNumberFormatter(currency: Settings.shared.primaryCurrency.value)
        guard var output = numberFormatter.validate(input) else { return false }
        if output.isEmpty {
            output = "0"
        }
        
        let primaryString = NSMutableAttributedString(string: Settings.shared.primaryCurrency.value.symbol, attributes: [.font: UIFont.Zap.regular])
        primaryString.append(NSAttributedString(string: output, attributes: [.font: UIFont.Zap.light.withSize(72)]))
        primaryCurrencyLabel.attributedText = primaryString
        
        satoshis = Settings.shared.primaryCurrency.value.satoshis(from: output) ?? 0
        
        secondaryCurrencyLabel.text = Settings.shared.secondaryCurrency.value.format(satoshis: satoshis)
        
        return true
    }
    
    @IBAction private func presentWaiterRequest(_ sender: Any) {
        guard let lightningService = lightningService else { return }
        let waiterRequestViewModel = WaiterRequestViewModel(amount: satoshis, transactionService: lightningService.transactionService, shoppingCartViewModel: nil)
        let tipViewController = UIStoryboard.instantiateTipViewController(waiterRequestViewModel: waiterRequestViewModel)
        let navigationController = ZapNavigationController(rootViewController: tipViewController)
        present(navigationController, animated: true, completion: nil)
    }
}
