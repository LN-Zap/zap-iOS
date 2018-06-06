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

final class LightningInvoiceViewModel: NSObject, TransactionViewModel {
    var detailViewModel: DetailViewModel {
        return LightningInvoiceDetailViewModel(lightningInvoice: lightningInvoice, annotation: annotation)
    }
    
    let icon = Observable<TransactionIcon>(.unsettledInvoice)
    
    var id: String {
        return lightningInvoice.id
    }
    
    var date: Date {
        return lightningInvoice.date
    }
    
    let annotation: Observable<TransactionAnnotation>
    let lightningInvoice: LightningInvoice
    
    let displayText: Observable<String>
    let amount: Observable<Satoshi?>
    
    let state: Observable<LightningInvoiceState>
    
    init(lightningInvoice: LightningInvoice, annotation: TransactionAnnotation) {
        self.annotation = Observable(annotation)
        self.lightningInvoice = lightningInvoice
        
        if !lightningInvoice.memo.isEmpty {
            displayText = Observable(lightningInvoice.memo)
        } else {
            displayText = Observable(lightningInvoice.paymentRequest)
        }
        
        if lightningInvoice.amount > 0 {
            amount = Observable(lightningInvoice.amount)
        } else {
            amount = Observable(nil)
        }
        
        if lightningInvoice.settled {
            state = Observable(.settled)
        } else if lightningInvoice.expiry < Date() {
            state = Observable(.expired)
        } else {
            state = Observable(.unsettled)
        }
        
        super.init()
    }
}
