//
//  Library
//
//  Created by Otto Suess on 15.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation
import Lightning

final class UnconfirmedTransactionViewModel: TransactionViewModel {
    let unconfirmedTransaction: UnconfirmedTransaction
    
    init(unconfirmedTransaction: UnconfirmedTransaction, annotation: TransactionAnnotation) {
        self.unconfirmedTransaction = unconfirmedTransaction
        
        let displayTextString = UnconfirmedTransactionViewModel.displayTextForAnnotation(annotation, unconfirmedTransaction: unconfirmedTransaction)
        
        super.init(transaction: unconfirmedTransaction, annotation: annotation, displayText: displayTextString, amount: unconfirmedTransaction.amount, icon: .unconfirmed)
    }
    
    private static func displayTextForAnnotation(_ annotation: TransactionAnnotation, unconfirmedTransaction: UnconfirmedTransaction) -> String {
        if let customMemo = annotation.customMemo {
            return customMemo
        }
        return unconfirmedTransaction.destinationAddress
    }
}
