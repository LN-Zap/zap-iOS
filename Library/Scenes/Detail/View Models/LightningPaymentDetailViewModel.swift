//
//  Zap
//
//  Created by Otto Suess on 06.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning

final class LightningPaymentDetailViewModel: NSObject, DetailViewModel {
    let detailViewControllerTitle = "scene.transaction_detail.title.payment_detail".localized
    let detailCells = MutableObservableArray<DetailCellType>([])
    
    init(lightningPayment: LightningPayment, annotation: Observable<TransactionAnnotation>, transactionListViewModel: TransactionListViewModel) {
        super.init()
        
        if let amountString = Settings.shared.primaryCurrency.value.format(satoshis: lightningPayment.amount) {
            detailCells.append(.info(DetailTableViewCell.Info(title: "scene.transaction_detail.amount_label".localized, data: amountString)))
            detailCells.append(.separator)
        }
        
        if let feeString = Settings.shared.primaryCurrency.value.format(satoshis: lightningPayment.fees) {
            detailCells.append(.info(DetailTableViewCell.Info(title: "scene.transaction_detail.fee_label".localized, data: feeString)))
            detailCells.append(.separator)
        }
        
        let dateString = DateFormatter.localizedString(from: lightningPayment.date, dateStyle: .medium, timeStyle: .short)
        detailCells.append(.info(DetailTableViewCell.Info(title: "scene.transaction_detail.date_label".localized, data: dateString)))
        detailCells.append(.separator)
        
        detailCells.append(DetailCellType.memoCell(transaction: lightningPayment, annotation: annotation, transactionListViewModel: transactionListViewModel, placeholder: lightningPayment.paymentHash))
        detailCells.append(.separator)
        
        detailCells.append(DetailCellType.hideTransactionCell(transaction: lightningPayment, annotation: annotation.value, transactionListViewModel: transactionListViewModel))
    }
}
