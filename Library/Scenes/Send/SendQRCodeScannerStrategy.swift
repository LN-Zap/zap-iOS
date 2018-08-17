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
    
    func viewControllerForAddress(address: String, lightningService: LightningService) -> Result<UIViewController>? {
        let sendViewModel = SendViewModel(lightningService: lightningService)
        let result = sendViewModel.paymentURI(for: address)
        
        return result.map {
            if let bitcoinURI = $0 as? BitcoinURI {
                let sendOnChainViewModel = SendOnChainViewModel(transactionAnnotationStore: transactionAnnotationStore, lightningService: lightningService, bitcoinURI: bitcoinURI)
                return UIStoryboard.instantiateSendOnChainViewController(with: sendOnChainViewModel)
            } else if let lightningURI = $0 as? LightningInvoiceURI {
                let sendLightningInvoiceViewModel = SendLightningInvoiceViewModel(transactionAnnotationStore: transactionAnnotationStore, nodeStore: nodeStore, transactionService: lightningService.transactionService, lightningInvoice: lightningURI.address)
                return UIStoryboard.instantiateSendLightningInvoiceViewController(with: sendLightningInvoiceViewModel)
            } else {
                fatalError("No ViewController implemented for URI")
            }
        }
    }
}
