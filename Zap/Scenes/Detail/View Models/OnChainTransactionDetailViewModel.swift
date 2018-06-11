//
//  Zap
//
//  Created by Otto Suess on 06.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

final class OnChainTransactionDetailViewModel: NSObject, DetailViewModel {
    let detailViewControllerTitle = "Transaction Detail"
    let detailCells = MutableObservableArray<DetailCellType>([])
    
    init(onChainTransaction: OnChainTransaction, annotation: Observable<TransactionAnnotation>, network: Network, transactionListViewModel: TransactionListViewModel) {
        super.init()
        
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
        
        if let cell = DetailCellType.blockExplorerCell(txid: onChainTransaction.id, title: "Transaction ID:", network: network) {
            detailCells.append(cell)
        }
        
        detailCells.append(DetailCellType.hideTransactionCell(transaction: onChainTransaction, transactionListViewModel: transactionListViewModel))
    }
}
