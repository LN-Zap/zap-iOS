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
    fileprivate var lightningService: LightningService?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.Zap.background
    }
}
