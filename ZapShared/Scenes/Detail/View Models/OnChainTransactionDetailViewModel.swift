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
    let detailViewControllerTitle = "scene.transaction_detail.title.transaction_detail".localized
    let detailCells = MutableObservableArray<DetailCellType>([])
    
    init(onChainTransaction: OnChainTransaction, annotation: Observable<TransactionAnnotation>, network: Network, transactionListViewModel: TransactionListViewModel) {
        super.init()
        
        if let amountString = Settings.shared.primaryCurrency.value.format(satoshis: onChainTransaction.amount) {
            detailCells.append(.info(DetailTableViewCell.Info(title: "scene.transaction_detail.amount_label".localized, data: amountString)))
        }
        
        let feesString = Settings.shared.primaryCurrency.value.format(satoshis: onChainTransaction.fees) ?? "0"
        detailCells.append(.info(DetailTableViewCell.Info(title: "scene.transaction_detail.fee_label".localized, data: feesString)))
        
        let dateString = DateFormatter.localizedString(from: onChainTransaction.date, dateStyle: .medium, timeStyle: .short)
        detailCells.append(.info(DetailTableViewCell.Info(title: "scene.transaction_detail.date_label".localized, data: dateString)))
        
        detailCells.append(.info(DetailTableViewCell.Info(title: "scene.transaction_detail.address_label".localized, data: onChainTransaction.firstDestinationAddress)))
        
        let confirmationString = onChainTransaction.confirmations > 10 ? "10+" : String(onChainTransaction.confirmations)
        detailCells.append(.info(DetailTableViewCell.Info(title: "scene.transaction_detail.confirmations_label".localized, data: confirmationString)))
        
        // TODO: show displayText instead of firstDestinationAddress
        let observableMemo = Observable<String?>(nil)
        annotation
            .observeNext {
                observableMemo.value = $0.customMemo
            }
            .dispose(in: reactive.bag)
        detailCells.append(.memo(DetailMemoTableViewCell.Info(memo: observableMemo, placeholder: onChainTransaction.firstDestinationAddress)))
        
        if let cell = DetailCellType.blockExplorerCell(txid: onChainTransaction.id, title: "scene.transaction_detail.transaction_id_label".localized, network: network) {
            detailCells.append(cell)
        }
        
        detailCells.append(DetailCellType.hideTransactionCell(transaction: onChainTransaction, transactionListViewModel: transactionListViewModel))
    }
}
