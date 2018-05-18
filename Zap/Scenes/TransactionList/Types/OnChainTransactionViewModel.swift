//
//  Zap
//
//  Created by Otto Suess on 14.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation
import ReactiveKit

final class OnChainTransactionViewModel: NSObject, TransactionViewModel {
    var id: String {
        return onChainTransaction.id
    }
    
    var date: Date {
        return onChainTransaction.date
    }
    
    let annotation: Observable<TransactionAnnotation>
    let onChainTransaction: OnChainTransaction
    
    let displayText: Signal<String, NoError>
    let amount: Signal<Satoshi, NoError>
    let time: String
    
    init(onChainTransaction: OnChainTransaction, annotation: TransactionAnnotation) {
        self.annotation = Observable(annotation)
        self.onChainTransaction = onChainTransaction
        
        time = DateFormatter.localizedString(from: onChainTransaction.date, dateStyle: .none, timeStyle: .short)
        
        amount = self.annotation
            .map { annotation -> Satoshi in
                if let type = annotation.type,
                    case .openChannelTransaction = type {
                    return -onChainTransaction.fees
                }
                return onChainTransaction.amount
            }
        
        displayText = self.annotation
            .map { annotation -> String in
                if let type = annotation.type,
                    case .openChannelTransaction(let channelPubKey) = type {
                    return "Open Channel: \(channelPubKey)"
                }
                return onChainTransaction.firstDestinationAddress
            }
    }
}
