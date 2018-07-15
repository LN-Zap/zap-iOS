//
//  Library
//
//  Created by Otto Suess on 15.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation
import Lightning

final class UnconfirmedTransactionDetailViewModel: NSObject, DetailViewModel {
    let detailViewControllerTitle = "scene.transaction_detail.title.transaction_detail".localized
    let detailCells = MutableObservableArray<DetailCellType>([])
    
    init(unconfirmedTransaction: UnconfirmedTransaction, annotation: Observable<TransactionAnnotation>, network: Network, transactionListViewModel: TransactionListViewModel) {
        super.init()
        
        if let amountString = Settings.shared.primaryCurrency.value.format(satoshis: unconfirmedTransaction.amount) {
            detailCells.append(.info(DetailTableViewCell.Info(title: "scene.transaction_detail.amount_label".localized, data: amountString)))
        }
        detailCells.append(.separator)
        
        let dateString = DateFormatter.localizedString(from: unconfirmedTransaction.date, dateStyle: .medium, timeStyle: .short)
        detailCells.append(.info(DetailTableViewCell.Info(title: "scene.transaction_detail.date_label".localized, data: dateString)))
        detailCells.append(.separator)
        
        detailCells.append(.info(DetailTableViewCell.Info(title: "scene.transaction_detail.address_label".localized, data: unconfirmedTransaction.destinationAddress)))
        detailCells.append(.separator)
        
        let confirmationString = "0"
        detailCells.append(.info(DetailTableViewCell.Info(title: "scene.transaction_detail.confirmations_label".localized, data: confirmationString)))
        detailCells.append(.separator)
        
        detailCells.append(DetailCellType.memoCell(transaction: unconfirmedTransaction, annotation: annotation, transactionListViewModel: transactionListViewModel, placeholder: unconfirmedTransaction.destinationAddress))
        detailCells.append(.separator)
        
        if let cell = DetailCellType.blockExplorerCell(txid: unconfirmedTransaction.id, title: "scene.transaction_detail.transaction_id_label".localized, network: network) {
            detailCells.append(cell)
            detailCells.append(.separator)
        }
        
        detailCells.append(DetailCellType.hideTransactionCell(transaction: unconfirmedTransaction, annotation: annotation.value, transactionListViewModel: transactionListViewModel))
    }
}
