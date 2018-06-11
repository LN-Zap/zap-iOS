//
//  Zap
//
//  Created by Otto Suess on 06.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation

final class LightningInvoiceDetailViewModel: NSObject, DetailViewModel {
    let detailViewControllerTitle = "Invoice Detail"
    let detailCells = MutableObservableArray<DetailCellType>([])
    
    init(lightningInvoice: LightningInvoice, annotation: Observable<TransactionAnnotation>, transactionListViewModel: TransactionListViewModel) {
        super.init()
        
        if lightningInvoice.expiry > Date() {
            detailCells.append(.qrCode(lightningInvoice.paymentRequest))
        }
        
        if let amountString = lightningInvoice.amount > 0 ? Settings.primaryCurrency.value.format(satoshis: lightningInvoice.amount) : "Unspecified" {
            detailCells.append(.info(DetailTableViewCell.Info(title: "Amount", data: amountString)))
        }
        
        let dateString = DateFormatter.localizedString(from: lightningInvoice.date, dateStyle: .medium, timeStyle: .short)
        detailCells.append(.info(DetailTableViewCell.Info(title: "Created", data: dateString)))
        
        detailCells.append(.info(DetailTableViewCell.Info(title: "Payment Request", data: lightningInvoice.paymentRequest)))
        
        let observableMemo = Observable<String?>(nil)
        annotation
            .observeNext {
                observableMemo.value = $0.customMemo
            }
            .dispose(in: reactive.bag)
        detailCells.append(.memo(DetailMemoTableViewCell.Info(memo: observableMemo, placeholder: lightningInvoice.memo)))
        
        detailCells.append(.timer(DetailTimerTableViewCell.Info(title: "Expiry", date: lightningInvoice.expiry)))
        
        let settledString = lightningInvoice.settled ? "Settled" : "Unsettled"
        detailCells.append(.info(DetailTableViewCell.Info(title: "Settled", data: settledString)))
        
        if let settleDate = lightningInvoice.settleDate {
            let dateString = DateFormatter.localizedString(from: settleDate, dateStyle: .medium, timeStyle: .short)
            detailCells.append(.info(DetailTableViewCell.Info(title: "Settled Date", data: dateString)))
        }
        
        detailCells.append(DetailCellType.hideTransactionCell(transaction: lightningInvoice, transactionListViewModel: transactionListViewModel))
    }
}
