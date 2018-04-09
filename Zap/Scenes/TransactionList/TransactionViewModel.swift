//
//  Zap
//
//  Created by Otto Suess on 06.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation
import ReactiveKit

final class TransactionViewModel {
    let transaction: Transaction
    
    let isOnChain: Bool
    let displayText: Observable<String>
    let amount: Satoshi
    let bag = DisposeBag()
    let time: String
    
    init(transaction: Transaction) {
        self.transaction = transaction
        
        if let blockchainTransaction = transaction as? BlockchainTransaction {
            isOnChain = true
            if let alias = MemoryTransactionMetadataStore.instance.metadata(for: transaction)?.fundingChannelAlias {
                displayText = Observable("Open Channel: \(alias)")
            } else {
                displayText = Observable(blockchainTransaction.firstDestinationAddress)
            }
        } else if let payment = transaction as? Payment {
            isOnChain = false
            displayText = Observable(payment.paymentHash)
        } else {
            fatalError("transaction type not implemented.")
        }
        
        amount = transaction.amount
        
        time = DateFormatter.localizedString(from: transaction.date, dateStyle: .none, timeStyle: .short)
        
        NotificationCenter.default.reactive
            .notification(name: .TransactionMetadataChanged)
            .observeNext { [displayText] notification in
                guard
                    let notificationTransaction = notification.userInfo?["transaction"] as? Transaction,
                    notificationTransaction as? BlockchainTransaction == transaction as? BlockchainTransaction,
                    let metadata = notification.userInfo?["metadata"] as? TransactionMetadata,
                    let alias = metadata.fundingChannelAlias
                    else { return }

                displayText.value = "Open Channel: \(alias)"
            }
            .dispose(in: bag)
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
