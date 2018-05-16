//
//  Zap
//
//  Created by Otto Suess on 14.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

final class LightningPaymentViewModel: TransactionViewModel {
    var date: Date {
        return lightningPayment.date
    }
    
    let annotation: Observable<TransactionAnnotation>
    let lightningPayment: LightningPayment
    
    let displayText: String
    let amount: Satoshi
    let time: String
    
    init(lightningPayment: LightningPayment, annotation: TransactionAnnotation) {
        self.annotation = Observable(annotation)
        self.lightningPayment = lightningPayment
        
        displayText = lightningPayment.paymentHash
        amount = lightningPayment.amount
        time = DateFormatter.localizedString(from: lightningPayment.date, dateStyle: .none, timeStyle: .short)
    }
}
