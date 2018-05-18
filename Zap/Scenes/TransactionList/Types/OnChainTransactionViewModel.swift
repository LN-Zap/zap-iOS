//
//  Zap
//
//  Created by Otto Suess on 14.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

final class OnChainTransactionViewModel: NSObject, TransactionViewModel {
    var id: String {
        return onChainTransaction.id
    }
    
    var date: Date {
        return onChainTransaction.date
    }
    
    let annotation: Observable<TransactionAnnotation>
    let onChainTransaction: OnChainTransaction
    
    let displayText: Observable<String>
    let amount: Observable<Satoshi>
    let time: String
    
    init(onChainTransaction: OnChainTransaction, annotation: TransactionAnnotation) {
        self.annotation = Observable(annotation)
        self.onChainTransaction = onChainTransaction
        
        displayText = Observable(onChainTransaction.firstDestinationAddress)
        amount = Observable(onChainTransaction.amount)
        
        time = DateFormatter.localizedString(from: onChainTransaction.date, dateStyle: .none, timeStyle: .short)
    }
}
