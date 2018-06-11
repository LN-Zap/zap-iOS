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

final class OnChainTransactionViewModel: TransactionViewModel {
    let onChainTransaction: OnChainTransaction
    let aliasStore: ChannelAliasStore
    
    init(onChainTransaction: OnChainTransaction, annotation: TransactionAnnotation, aliasStore: ChannelAliasStore) {
        self.onChainTransaction = onChainTransaction
        self.aliasStore = aliasStore
        
        let initialIcon = OnChainTransactionViewModel.iconForAnnotation(annotation)
        let initialAmount = OnChainTransactionViewModel.amountForAnnotation(annotation, onChainTransaction: onChainTransaction)
        let displayTextString = OnChainTransactionViewModel.displayTextForAnnotation(annotation, onChainTransaction: onChainTransaction, aliasStore: aliasStore)
        
        super.init(transaction: onChainTransaction, annotation: annotation, displayText: displayTextString, amount: initialAmount, icon: initialIcon)
        
        self.annotation
            .observeNext { [amount, displayText, icon] in
                amount.value = OnChainTransactionViewModel.amountForAnnotation($0, onChainTransaction: onChainTransaction)
                displayText.value = OnChainTransactionViewModel.displayTextForAnnotation($0, onChainTransaction: onChainTransaction, aliasStore: aliasStore)
                icon.value = OnChainTransactionViewModel.iconForAnnotation(annotation)
            }
            .dispose(in: reactive.bag)
    }
    
    private static func amountForAnnotation(_ annotation: TransactionAnnotation, onChainTransaction: OnChainTransaction) -> Satoshi {
        if let type = annotation.type,
            case .openChannelTransaction = type {
            return -onChainTransaction.fees
        }
        return onChainTransaction.amount
    }
    
    private static func displayTextForAnnotation(_ annotation: TransactionAnnotation, onChainTransaction: OnChainTransaction, aliasStore: ChannelAliasStore) -> String {
        if let customMemo = annotation.customMemo {
            return customMemo
        } else if let type = annotation.type,
            case .openChannelTransaction(let channelPubKey) = type {
            let alias = aliasStore.data[channelPubKey] ?? channelPubKey
            return "Open Channel: \(alias)"
        }
        return onChainTransaction.firstDestinationAddress
    }
    
    private static func iconForAnnotation(_ annotation: TransactionAnnotation) -> TransactionIcon {
        if let type = annotation.type,
            case .openChannelTransaction = type {
            return .openChannel
        } else {
            return .onChain
        }
    }
}
