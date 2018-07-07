//
//  Zap
//
//  Created by Otto Suess on 25.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation
import Lightning

struct SendQRCodeScannerStrategy: QRCodeScannerStrategy {
    let title = "scene.deposit.send".localized
    let transactionAnnotationStore: TransactionAnnotationStore
    
    init(transactionAnnotationStore: TransactionAnnotationStore) {
        self.transactionAnnotationStore = transactionAnnotationStore
    }
    
    func viewControllerForAddress(address: String, lightningService: LightningService) -> UIViewController? {
        if let bitcoinURI = BitcoinURI(string: address) {
            let sendOnChainViewModel = SendOnChainViewModel(lightningService: lightningService, bitcoinURI: bitcoinURI)
            return UIStoryboard.instantiateSendOnChainViewController(with: sendOnChainViewModel)
        } else if let lightningURI = LightningInvoiceURI(string: address) {
            let sendLightningInvoiceViewModel = SendLightningInvoiceViewModel(transactionAnnotationStore: transactionAnnotationStore, transactionService: lightningService.transactionService, lightningInvoice: lightningURI.address)
            return UIStoryboard.instantiateSendLightningInvoiceViewController(with: sendLightningInvoiceViewModel)
        } else {
            return nil
        }
    }
}
