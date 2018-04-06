//
//  Zap
//
//  Created by Otto Suess on 06.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation

final class TransactionViewModel {
    let transaction: Transaction
    
    let isOnChain: Bool
    let displayText: String
    let amount: Satoshi

    init(transaction: Transaction) {
        self.transaction = transaction
        
        if let blockchainTransaction = transaction as? BlockchainTransaction {
            isOnChain = true
            displayText = blockchainTransaction.firstDestinationAddress
        } else if let payment = transaction as? Payment {
            isOnChain = false
            displayText = payment.paymentHash
        } else {
            fatalError("transaction type not implemented.")
        }
        
        amount = transaction.amount
    }
}

extension TransactionViewModel: Equatable {
    static func == (lhs: TransactionViewModel, rhs: TransactionViewModel) -> Bool {
        if let lhs = lhs.transaction as? BlockchainTransaction,
            let rhs = rhs.transaction as? BlockchainTransaction {
            return lhs == rhs
        } else if let lhs = lhs.transaction as? Payment,
            let rhs = rhs.transaction as? Payment {
            return lhs == rhs
        }
        return false
    }
}
