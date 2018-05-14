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

final class LightningInvoiceViewModel {
    let lightningInvoice: LightningInvoice
    
    let displayText: String
    let amount: Satoshi
    let time: String
    
    let state: Observable<LightningInvoiceState>
    
    init(lightningInvoice: LightningInvoice) {
        self.lightningInvoice = lightningInvoice
        
        if !lightningInvoice.memo.isEmpty {
            displayText = lightningInvoice.memo
        } else {
            displayText = lightningInvoice.paymentRequest
        }
        
        amount = lightningInvoice.amount
        time = DateFormatter.localizedString(from: lightningInvoice.date, dateStyle: .none, timeStyle: .short)
        
        if lightningInvoice.settled {
            state = Observable(.settled)
        } else if lightningInvoice.expiry < Date() {
            state = Observable(.expired)
        } else {
            state = Observable(.unsettled)
        }
    }
}
