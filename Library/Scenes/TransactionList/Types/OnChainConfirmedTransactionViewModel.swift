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

final class OnChainConfirmedTransactionViewModel: TransactionViewModel {
    let onChainTransaction: OnChainConfirmedTransaction
    let nodeStore: LightningNodeStore
    
    init(onChainTransaction: OnChainConfirmedTransaction, annotation: TransactionAnnotation, nodeStore: LightningNodeStore) {
        self.onChainTransaction = onChainTransaction
        self.nodeStore = nodeStore
        
        let initialIcon = OnChainConfirmedTransactionViewModel.iconForAnnotation(annotation)
        let initialAmount = OnChainConfirmedTransactionViewModel.amountForAnnotation(annotation, onChainTransaction: onChainTransaction)
        let displayTextString = OnChainConfirmedTransactionViewModel.displayTextForAnnotation(annotation, onChainTransaction: onChainTransaction, nodeStore: nodeStore)
        
        super.init(transaction: onChainTransaction, annotation: annotation, displayText: displayTextString, amount: initialAmount, icon: initialIcon)
        
        self.annotation
            .observeNext { [amount, displayText, icon] in
                amount.value = OnChainConfirmedTransactionViewModel.amountForAnnotation($0, onChainTransaction: onChainTransaction)
                displayText.value = OnChainConfirmedTransactionViewModel.displayTextForAnnotation($0, onChainTransaction: onChainTransaction, nodeStore: nodeStore)
                icon.value = OnChainConfirmedTransactionViewModel.iconForAnnotation(annotation)
            }
            .dispose(in: reactive.bag)
    }
    
    private static func amountForAnnotation(_ annotation: TransactionAnnotation, onChainTransaction: OnChainConfirmedTransaction) -> Satoshi {
        if let type = annotation.type,
            let fees = onChainTransaction.fees {
            switch type {
            case .openChannelTransaction, .closeChannelTransaction:
                return fees == 0 ? fees : -fees
            }
        }
        return onChainTransaction.amount
    }
    
    private static func displayTextForAnnotation(_ annotation: TransactionAnnotation, onChainTransaction: OnChainConfirmedTransaction, nodeStore: LightningNodeStore) -> String {
        if let customMemo = annotation.customMemo {
            return customMemo
        } else if let type = annotation.type {
            switch type {
            case .openChannelTransaction(let remotePubKey):
                let alias = nodeStore.data[remotePubKey]?.alias ?? remotePubKey
                return String(format: "transaction.open_channel.memo".localized, alias)
            case let .closeChannelTransaction(remotePubKey, type):
                let alias = nodeStore.data[remotePubKey]?.alias ?? remotePubKey
                return String(format: "transaction.close_channel.memo".localized, type.localized, alias)
            }
        }
        return onChainTransaction.destinationAddresses.first?.string ?? "transaction.no_destination_address".localized
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
