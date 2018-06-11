//
//  Zap
//
//  Created by Otto Suess on 25.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation

struct SendQRCodeScannerStrategy: QRCodeScannerStrategy {
    let title = "scene.deposit.send".localized
    let addressTypes: [AddressType] = [.bitcoinAddress, .lightningInvoice]
    let transactionAnnotationStore: TransactionAnnotationStore
    
    init(transactionAnnotationStore: TransactionAnnotationStore) {
        self.transactionAnnotationStore = transactionAnnotationStore
    }
    
    func viewControllerForAddressType(_ type: AddressType, address: String, viewModel: LightningService) -> UIViewController? {
        switch type {
        case .lightningInvoice:
            let sendLightningInvoiceViewModel = SendLightningInvoiceViewModel(transactionAnnotationStore: transactionAnnotationStore, transactionService: viewModel.transactionService, lightningInvoice: address)
            return UIStoryboard.instantiateSendLightningInvoiceViewController(with: sendLightningInvoiceViewModel)
        case .bitcoinAddress:
            let sendOnChainViewModel = SendOnChainViewModel(viewModel: viewModel, address: address)
            return UIStoryboard.instantiateSendOnChainViewController(with: sendOnChainViewModel)
        default:
            return nil
        }
    }
}
