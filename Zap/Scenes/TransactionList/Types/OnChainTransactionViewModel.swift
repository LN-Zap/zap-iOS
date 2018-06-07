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
    let icon: Observable<TransactionIcon>
    
    var id: String {
        return onChainTransaction.id
    }
    
    var date: Date {
        return onChainTransaction.date
    }
    
    let annotation: Observable<TransactionAnnotation>
    let onChainTransaction: OnChainTransaction
    let aliasStore: ChannelAliasStore
    
    let displayText: Observable<String>
    let amount: Observable<Satoshi?>
    
    init(onChainTransaction: OnChainTransaction, annotation: TransactionAnnotation, aliasStore: ChannelAliasStore) {
        self.annotation = Observable(annotation)
        self.onChainTransaction = onChainTransaction
        self.aliasStore = aliasStore
        
        self.icon = Observable(OnChainTransactionViewModel.iconForAnnotation(annotation))
        self.amount = Observable(OnChainTransactionViewModel.amountForAnnotation(annotation, onChainTransaction: onChainTransaction))
        self.displayText = Observable(OnChainTransactionViewModel.displayTextForAnnotation(annotation, onChainTransaction: onChainTransaction, aliasStore: aliasStore))
        
        super.init()
        
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
