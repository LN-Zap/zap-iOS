//
//  Zap
//
//  Created by Otto Suess on 14.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

private func displayTextForAnnotation(_ annotation: TransactionAnnotation, lightningPayment: LightningPayment) -> String {
    if let customMemo = annotation.customMemo, customMemo != "" {
        return customMemo
    }
    return lightningPayment.paymentHash
}

final class LightningPaymentViewModel: NSObject, TransactionViewModel {
    let icon = Observable<TransactionIcon>(.lightningPayment)
    
    var id: String {
        return lightningPayment.id
    }
    
    var date: Date {
        return lightningPayment.date
    }
    
    let annotation: Observable<TransactionAnnotation>
    let lightningPayment: LightningPayment
    
    let displayText: Observable<String>
    let amount: Observable<Satoshi?>
    
    init(lightningPayment: LightningPayment, annotation: TransactionAnnotation) {
        self.annotation = Observable(annotation)
        self.lightningPayment = lightningPayment
        
        displayText = Observable(displayTextForAnnotation(annotation, lightningPayment: lightningPayment))
        amount = Observable(lightningPayment.amount)
        
        super.init()
        
        self.annotation
            .observeNext { [displayText] in
                displayText.value = displayTextForAnnotation($0, lightningPayment: lightningPayment)
            }
            .dispose(in: reactive.bag)
    }
}
