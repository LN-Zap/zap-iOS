//
//  Zap
//
//  Created by Otto Suess on 06.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation
import Lightning
import SwiftLnd

final class OnChainTransactionDetailViewModel: NSObject, DetailViewModel {
    let detailViewControllerTitle = "scene.transaction_detail.title.transaction_detail".localized
    let detailCells = MutableObservableArray<DetailCellType>([])
    
    init(onChainTransaction: OnChainTransaction, annotation: Observable<TransactionAnnotation>, historyViewModel: HistoryViewModel) {
        super.init()
        
        if let amountString = Settings.shared.primaryCurrency.value.format(satoshis: onChainTransaction.amount) {
            detailCells.append(.info(DetailTableViewCell.Info(title: "scene.transaction_detail.amount_label".localized, data: amountString)))
        }
        detailCells.append(.separator)
        
        if let fees = onChainTransaction.fees {
            let feesString = Settings.shared.primaryCurrency.value.format(satoshis: fees) ?? "0"
            detailCells.append(.info(DetailTableViewCell.Info(title: "scene.transaction_detail.fee_label".localized, data: feesString)))
            detailCells.append(.separator)
        }
        
        let dateString = DateFormatter.localizedString(from: onChainTransaction.date, dateStyle: .medium, timeStyle: .short)
        detailCells.append(.info(DetailTableViewCell.Info(title: "scene.transaction_detail.date_label".localized, data: dateString)))
        detailCells.append(.separator)

        if let address = onChainTransaction.destinationAddresses.first {
            detailCells.append(DetailCellType.blockExplorerCell(title: "scene.transaction_detail.address_label".localized, code: address.string, type: .address))
            detailCells.append(.separator)
        }
        
        detailCells.append(DetailCellType.blockExplorerCell(title: "scene.transaction_detail.transaction_id_label".localized, code: onChainTransaction.id, type: .transactionId))
        detailCells.append(.separator)

        let confirmationString = onChainTransaction.confirmations > 10 ? "10+" : String(onChainTransaction.confirmations)
        detailCells.append(.info(DetailTableViewCell.Info(title: "scene.transaction_detail.confirmations_label".localized, data: confirmationString)))
        detailCells.append(.separator)

        let placeholder = onChainTransaction.destinationAddresses.first?.string ?? "generic.memo.placeholder".localized
        detailCells.append(DetailCellType.memoCell(transaction: onChainTransaction, annotation: annotation, historyViewModel: historyViewModel, placeholder: placeholder))
        detailCells.append(.separator)

        detailCells.append(DetailCellType.hideTransactionCell(transaction: onChainTransaction, annotation: annotation.value, historyViewModel: historyViewModel))
    }
}
