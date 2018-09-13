//
//  Library
//
//  Created by Otto Suess on 15.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation
import Lightning
import SwiftLnd

final class OnChainUnconfirmedTransactionViewModel: TransactionViewModel {
    let unconfirmedTransaction: OnChainUnconfirmedTransaction
    
    init(unconfirmedTransaction: OnChainUnconfirmedTransaction, annotation: TransactionAnnotation) {
        self.unconfirmedTransaction = unconfirmedTransaction
        
        let displayTextString = OnChainUnconfirmedTransactionViewModel.displayTextForAnnotation(annotation, unconfirmedTransaction: unconfirmedTransaction)
        
        super.init(transaction: unconfirmedTransaction, annotation: annotation, displayText: displayTextString, amount: unconfirmedTransaction.amount, icon: .unconfirmed)
        
        self.annotation
            .map { OnChainUnconfirmedTransactionViewModel.displayTextForAnnotation($0, unconfirmedTransaction: unconfirmedTransaction) }
            .feedNext(into: displayText)
            .observeNext { _ in }
            .dispose(in: reactive.bag)
    }
    
    private static func displayTextForAnnotation(_ annotation: TransactionAnnotation, unconfirmedTransaction: OnChainUnconfirmedTransaction) -> String {
        if let customMemo = annotation.customMemo {
            return customMemo
        }
        return unconfirmedTransaction.destinationAddresses.first?.string ?? "transaction.no_destination_address".localized
    }
}
