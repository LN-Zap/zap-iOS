//
//  Zap
//
//  Created by Otto Suess on 14.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

final class OnChainTransactionViewModel: NSObject {
    let onChainTransaction: OnChainTransaction
    
    let displayText: Observable<String>
    let amount: Observable<Satoshi>
    let time: String
    
    init(onChainTransaction: OnChainTransaction) {
        self.onChainTransaction = onChainTransaction
        
        if let alias = MemoryTransactionMetadataStore.instance.metadata(for: onChainTransaction)?.fundingChannelAlias {
            displayText = Observable("Open Channel: \(alias)")
            amount = Observable(-onChainTransaction.fees)
        } else {
            displayText = Observable(onChainTransaction.firstDestinationAddress)
            amount = Observable(onChainTransaction.amount)
        }
        
        time = DateFormatter.localizedString(from: onChainTransaction.date, dateStyle: .none, timeStyle: .short)
        
        super.init()
        
        NotificationCenter.default.reactive
            .notification(name: .TransactionMetadataChanged)
            .observeNext { [displayText, amount] notification in
                guard
                    let notificationTransaction = notification.userInfo?["transaction"] as? Transaction,
                    notificationTransaction as? OnChainTransaction == onChainTransaction,
                    let metadata = notification.userInfo?["metadata"] as? TransactionMetadata,
                    let alias = metadata.fundingChannelAlias
                    else { return }
                
                amount.value = -notificationTransaction.fees
                displayText.value = "Open Channel: \(alias)"
            }
            .dispose(in: reactive.bag)
    }
}
