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

private func amountForAnnotation(_ annotation: TransactionAnnotation, onChainTransaction: OnChainTransaction) -> Satoshi {
    if let type = annotation.type,
        case .openChannelTransaction = type {
        return -onChainTransaction.fees
    }
    return onChainTransaction.amount
}

private func displayTextForAnnotation(_ annotation: TransactionAnnotation, onChainTransaction: OnChainTransaction, aliasStore: ChannelAliasStore) -> String {
    if let customMemo = annotation.customMemo {
        return customMemo
    } else if let type = annotation.type,
        case .openChannelTransaction(let channelPubKey) = type {
        let alias = aliasStore.data[channelPubKey] ?? channelPubKey
        return "Open Channel: \(alias)"
    }
    return onChainTransaction.firstDestinationAddress
}

private func iconForAnnotation(_ annotation: TransactionAnnotation) -> TransactionIcon {
    if let type = annotation.type,
        case .openChannelTransaction = type {
        return .openChannel
    } else {
        return .onChain
    }
}

final class OnChainTransactionViewModel: NSObject, TransactionViewModel {
    let icon: Observable<TransactionIcon>
    
    let detailViewControllerTitle = "Transaction Detail"
    
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
    let amount: Observable<Satoshi>
    
    let detailCells = MutableObservableArray<DetailCellType>([])
    
    init(onChainTransaction: OnChainTransaction, annotation: TransactionAnnotation, aliasStore: ChannelAliasStore) {
        self.annotation = Observable(annotation)
        self.onChainTransaction = onChainTransaction
        self.aliasStore = aliasStore
        
        self.icon = Observable(iconForAnnotation(annotation))
        self.amount = Observable(amountForAnnotation(annotation, onChainTransaction: onChainTransaction))
        self.displayText = Observable(displayTextForAnnotation(annotation, onChainTransaction: onChainTransaction, aliasStore: aliasStore))
        
        super.init()
        
        self.annotation
            .observeNext { [amount, displayText, icon] in
                amount.value = amountForAnnotation($0, onChainTransaction: onChainTransaction)
                displayText.value = displayTextForAnnotation($0, onChainTransaction: onChainTransaction, aliasStore: aliasStore)
                icon.value = iconForAnnotation(annotation)
            }
            .dispose(in: reactive.bag)
        
        setupInfoArray()
    }
    
    private func setupInfoArray() {
        if let amountString = Settings.primaryCurrency.value.format(satoshis: onChainTransaction.amount) {
            detailCells.append(.info(DetailTableViewCell.Info(title: "Amount", data: amountString)))
        }
        
        let feesString = Settings.primaryCurrency.value.format(satoshis: onChainTransaction.fees) ?? "0"
        detailCells.append(.info(DetailTableViewCell.Info(title: "Fees", data: feesString)))
        
        let dateString = DateFormatter.localizedString(from: onChainTransaction.date, dateStyle: .medium, timeStyle: .short)
        detailCells.append(.info(DetailTableViewCell.Info(title: "Date", data: dateString)))
        
        detailCells.append(.info(DetailTableViewCell.Info(title: "Address", data: onChainTransaction.firstDestinationAddress)))
        
        let confirmationString = onChainTransaction.confirmations > 10 ? "10+" : String(onChainTransaction.confirmations)
        detailCells.append(.info(DetailTableViewCell.Info(title: "Confirmations", data: confirmationString)))
        
        // TODO: show displayText instead of firstDestinationAddress
        let observableMemo = Observable<String?>(nil)
        annotation
            .observeNext {
                observableMemo.value = $0.customMemo
            }
            .dispose(in: reactive.bag)
        detailCells.append(.memo(DetailMemoTableViewCell.Info(memo: observableMemo, placeholder: onChainTransaction.firstDestinationAddress)))
    }

}
