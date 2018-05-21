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
    
    let displayText: Signal<String, NoError>
    let amount: Signal<Satoshi, NoError>
    let time: String
    
    let data = MutableObservableArray<DetailCellType>([])
    
    init(onChainTransaction: OnChainTransaction, annotation: TransactionAnnotation, aliasStore: ChannelAliasStore) {
        self.annotation = Observable(annotation)
        self.onChainTransaction = onChainTransaction
        self.aliasStore = aliasStore
        
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
                if let customMemo = annotation.customMemo {
                    return customMemo
                } else if let type = annotation.type,
                    case .openChannelTransaction(let channelPubKey) = type {
                    let alias = aliasStore.data[channelPubKey] ?? channelPubKey
                    return "Open Channel: \(alias)"
                }
                return onChainTransaction.firstDestinationAddress
            }
        
        super.init()
        
        setupInfoArray()
    }
    
    private func setupInfoArray() {
        if let amountString = Settings.primaryCurrency.value.format(satoshis: onChainTransaction.amount) {
            data.append(.info(DetailTableViewCell.Info(title: "Amount", data: amountString)))
        }
        
        let feesString = Settings.primaryCurrency.value.format(satoshis: onChainTransaction.fees) ?? "0"
        data.append(.info(DetailTableViewCell.Info(title: "Fees", data: feesString)))
        
        let dateString = DateFormatter.localizedString(from: onChainTransaction.date, dateStyle: .medium, timeStyle: .short)
        data.append(.info(DetailTableViewCell.Info(title: "Date", data: dateString)))
        
        data.append(.info(DetailTableViewCell.Info(title: "Address", data: onChainTransaction.firstDestinationAddress)))
        
        let confirmationString = onChainTransaction.confirmations > 10 ? "10+" : String(onChainTransaction.confirmations)
        data.append(.info(DetailTableViewCell.Info(title: "Confirmations", data: confirmationString)))
        
        // TODO: show displayText instead of firstDestinationAddress
        let observableMemo = Observable<String?>(nil)
        annotation
            .observeNext {
                observableMemo.value = $0.customMemo
            }
            .dispose(in: reactive.bag)
        data.append(.memo(DetailMemoTableViewCell.Info(memo: observableMemo, placeholder: onChainTransaction.firstDestinationAddress)))
    }

}
