//
//  Zap
//
//  Created by Otto Suess on 25.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation
import Lightning

class SendQRCodeScannerStrategy: QRCodeScannerStrategy {
    private let transactionAnnotationStore: TransactionAnnotationStore
    private let nodeStore: LightningNodeStore
    
    let title = "scene.deposit.send".localized
    
    init(transactionAnnotationStore: TransactionAnnotationStore, nodeStore: LightningNodeStore) {
        self.transactionAnnotationStore = transactionAnnotationStore
        self.nodeStore = nodeStore
    }
    
    func viewControllerForAddress(address: String, lightningService: LightningService, callback: (Result<UIViewController>) -> Void) {
        let sendViewModel = SendViewModel(lightningService: lightningService)
        let result = sendViewModel.paymentURI(for: address)

        if let bitcoinURI = result.value as? BitcoinURI {
            let sendOnChainViewModel = SendOnChainViewModel(transactionAnnotationStore: transactionAnnotationStore, lightningService: lightningService, bitcoinURI: bitcoinURI)
            callback(.success(UIStoryboard.instantiateSendOnChainViewController(with: sendOnChainViewModel)))
        } else if let lightningURI = result.value as? LightningInvoiceURI {
            let sendLightningInvoiceViewModel = SendLightningInvoiceViewModel(transactionAnnotationStore: transactionAnnotationStore, nodeStore: nodeStore, transactionService: lightningService.transactionService, lightningInvoice: lightningURI.address)
            callback(.success(UIStoryboard.instantiateSendLightningInvoiceViewController(with: sendLightningInvoiceViewModel)))
        } else {
            fatalError("No ViewController implemented for URI")
        }
    }
}
