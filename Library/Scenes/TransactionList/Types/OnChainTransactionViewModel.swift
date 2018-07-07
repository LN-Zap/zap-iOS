//
//  Zap
//
//  Created by Otto Suess on 14.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation
import Lightning
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
        if let type = annotation.type {
            switch type {
            case .openChannelTransaction, .closeChannelTransaction:
                return -onChainTransaction.fees
            }
        }
        return onChainTransaction.amount
    }
    
    private static func displayTextForAnnotation(_ annotation: TransactionAnnotation, onChainTransaction: OnChainTransaction, aliasStore: ChannelAliasStore) -> String {
        if let customMemo = annotation.customMemo {
            return customMemo
        } else if let type = annotation.type {
            switch type {
            case .openChannelTransaction(let remotePubKey):
                let alias = aliasStore.data[remotePubKey] ?? remotePubKey
                return String(format: "transaction.open_channel.memo".localized, alias)
            case let .closeChannelTransaction(remotePubKey, type):
                let alias = aliasStore.data[remotePubKey] ?? remotePubKey
                return String(format: "transaction.close_channel.memo".localized, type.localized, alias)
            }
        }
        return onChainTransaction.firstDestinationAddress
    }
    
    private static func iconForAnnotation(_ annotation: TransactionAnnotation) -> TransactionIcon {
        if let type = annotation.type {
            switch type {
            case .openChannelTransaction:
                return .openChannel
            case .closeChannelTransaction:
                return .closeChannel
            }
        } else {
            return .onChain
        }
    }
}
