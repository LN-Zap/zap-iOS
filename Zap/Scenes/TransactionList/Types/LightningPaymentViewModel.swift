//
//  Zap
//
//  Created by Otto Suess on 14.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation

final class LightningPaymentViewModel {
    let lightningPayment: LightningPayment
    
    let displayText: String
    let amount: Satoshi
    let time: String
    
    init(lightningPayment: LightningPayment) {
        self.lightningPayment = lightningPayment
        
        displayText = lightningPayment.paymentHash
        amount = lightningPayment.amount
        time = DateFormatter.localizedString(from: lightningPayment.date, dateStyle: .none, timeStyle: .short)
    }
}
