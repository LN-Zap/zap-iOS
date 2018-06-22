//
//  Zap
//
//  Created by Otto Suess on 06.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation

final class LightningPaymentDetailViewModel: NSObject, DetailViewModel {
    let detailViewControllerTitle = "scene.transaction_detail.title.payment_detail".localized
    let detailCells = MutableObservableArray<DetailCellType>([])
    
    init(lightningPayment: LightningPayment, annotation: Observable<TransactionAnnotation>, transactionListViewModel: TransactionListViewModel) {
        super.init()
        
        if let amountString = Settings.shared.primaryCurrency.value.format(satoshis: lightningPayment.amount) {
            detailCells.append(.info(DetailTableViewCell.Info(title: "scene.transaction_detail.amount_label".localized, data: amountString)))
        }
        
        if let feeString = Settings.shared.primaryCurrency.value.format(satoshis: lightningPayment.fees) {
            detailCells.append(.info(DetailTableViewCell.Info(title: "scene.transaction_detail.fee_label".localized, data: feeString)))
        }
        
        let dateString = DateFormatter.localizedString(from: lightningPayment.date, dateStyle: .medium, timeStyle: .short)
        detailCells.append(.info(DetailTableViewCell.Info(title: "scene.transaction_detail.date_label".localized, data: dateString)))
        
        let observableMemo = Observable<String?>(nil)
        annotation
            .observeNext {
                observableMemo.value = $0.customMemo
            }
            .dispose(in: reactive.bag)
        detailCells.append(.memo(DetailMemoTableViewCell.Info(memo: observableMemo, placeholder: lightningPayment.paymentHash)))
        
        detailCells.append(DetailCellType.hideTransactionCell(transaction: lightningPayment, transactionListViewModel: transactionListViewModel))
    }
}
