//
//  Zap
//
//  Created by Otto Suess on 14.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation

final class LightningInvoiceViewModel {
    let lightningInvoice: LightningInvoice
    
    let displayText: String
    let amount: Satoshi
    let time: String
    
    init(lightningInvoice: LightningInvoice) {
        self.lightningInvoice = lightningInvoice
        
        if !lightningInvoice.memo.isEmpty {
            displayText = lightningInvoice.memo
        } else {
            displayText = lightningInvoice.paymentRequest
        }
        
        amount = lightningInvoice.amount
        time = DateFormatter.localizedString(from: lightningInvoice.date, dateStyle: .none, timeStyle: .short)
    }
}
