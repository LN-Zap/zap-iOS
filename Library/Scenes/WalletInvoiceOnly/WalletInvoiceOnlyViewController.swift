//
//  Library
//
//  Created by Otto Suess on 02.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import Lightning

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
    @IBOutlet private weak var amountInputView: AmountInputView!
    @IBOutlet private weak var createInvoiceButton: UIButton!
    
    fileprivate var lightningService: LightningService?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.Zap.background
        
        amountInputView.backgroundColor = UIColor.Zap.background
        amountInputView.textColor = UIColor.Zap.white
        amountInputView.addTarget(self, action: #selector(amountChanged(sender:)), for: .valueChanged)
        
        Style.Button.background.apply(to: createInvoiceButton)
        
        createInvoiceButton.setTitle("Create Invoice", for: .normal)
    }
    
    @objc private func amountChanged(sender: AmountInputView) {
//        viewModel.amount = sender.satoshis
    }
}
