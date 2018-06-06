//
//  Zap
//
//  Created by Otto Suess on 06.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation

final class LightningPaymentDetailViewModel: NSObject, DetailViewModel {
    let detailViewControllerTitle = "Payment Detail"
    let detailCells = MutableObservableArray<DetailCellType>([])
    
    init(lightningPayment: LightningPayment, annotation: Observable<TransactionAnnotation>) {
        super.init()
        
        var cells = [DetailCellType]()

        if let amountString = Settings.primaryCurrency.value.format(satoshis: lightningPayment.amount) {
            cells.append(.info(DetailTableViewCell.Info(title: "Amount", data: amountString)))
        }
        
        if let feeString = Settings.primaryCurrency.value.format(satoshis: lightningPayment.fees) {
            cells.append(.info(DetailTableViewCell.Info(title: "Fee", data: feeString)))
        }
        
        let dateString = DateFormatter.localizedString(from: lightningPayment.date, dateStyle: .medium, timeStyle: .short)
        cells.append(.info(DetailTableViewCell.Info(title: "Date", data: dateString)))
        
        let observableMemo = Observable<String?>(nil)
        annotation
            .observeNext {
                observableMemo.value = $0.customMemo
            }
            .dispose(in: reactive.bag)
        cells.append(.memo(DetailMemoTableViewCell.Info(memo: observableMemo, placeholder: lightningPayment.paymentHash)))
        
        detailCells.replace(with: cells)
    }
}
