//
//  Zap
//
//  Created by Otto Suess on 14.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

enum LightningInvoiceState {
    case settled
    case unsettled
    case expired
}

final class LightningInvoiceViewModel: TransactionViewModel {
    let lightningInvoice: LightningInvoice
    let state: Observable<LightningInvoiceState>
    
    init(lightningInvoice: LightningInvoice, annotation: TransactionAnnotation) {
        self.lightningInvoice = lightningInvoice
        
        let displayTextString: String
        if !lightningInvoice.memo.isEmpty {
            displayTextString = lightningInvoice.memo
        } else {
            displayTextString = lightningInvoice.paymentRequest
        }
        
        let amount: Satoshi?
        if lightningInvoice.amount > 0 {
            amount = lightningInvoice.amount
        } else {
            amount = nil
        }
        
        if lightningInvoice.settled {
            state = Observable(.settled)
        } else if lightningInvoice.expiry < Date() {
            state = Observable(.expired)
        } else {
            state = Observable(.unsettled)
        }
        
        super.init(transaction: lightningInvoice, annotation: annotation, displayText: displayTextString, amount: amount, icon: .unsettledInvoice)
    }
}
