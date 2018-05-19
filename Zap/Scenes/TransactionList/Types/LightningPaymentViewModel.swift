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
    let detailViewControllerTitle = "Payment Detail"
    
    var id: String {
        return lightningPayment.id
    }
    
    var date: Date {
        return lightningPayment.date
    }
    
    let annotation: Observable<TransactionAnnotation>
    let lightningPayment: LightningPayment
    
    let displayText: String
    let amount: Satoshi
    let time: String
    
    let data = MutableObservableArray<DetailCellType>([])
    
    init(lightningPayment: LightningPayment, annotation: TransactionAnnotation) {
        self.annotation = Observable(annotation)
        self.lightningPayment = lightningPayment
        
        displayText = lightningPayment.paymentHash
        amount = lightningPayment.amount
        time = DateFormatter.localizedString(from: lightningPayment.date, dateStyle: .none, timeStyle: .short)
    }
}
