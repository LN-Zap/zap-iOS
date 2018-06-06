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
    
    init(lightningInvoice: LightningInvoice, annotation: Observable<TransactionAnnotation>) {
        super.init()
        
        var cells = [DetailCellType]()
        
        if lightningInvoice.expiry > Date() {
            cells.append(.qrCode(lightningInvoice.paymentRequest))
        }
        
        if let amountString = lightningInvoice.amount > 0 ? Settings.primaryCurrency.value.format(satoshis: lightningInvoice.amount) : "Unspecified" {
            cells.append(.info(DetailTableViewCell.Info(title: "Amount", data: amountString)))
        }
        
        let dateString = DateFormatter.localizedString(from: lightningInvoice.date, dateStyle: .medium, timeStyle: .short)
        cells.append(.info(DetailTableViewCell.Info(title: "Created", data: dateString)))
        
        cells.append(.info(DetailTableViewCell.Info(title: "Payment Request", data: lightningInvoice.paymentRequest)))
        
        let observableMemo = Observable<String?>(nil)
        annotation
            .observeNext {
                observableMemo.value = $0.customMemo
            }
            .dispose(in: reactive.bag)
        cells.append(.memo(DetailMemoTableViewCell.Info(memo: observableMemo, placeholder: lightningInvoice.memo)))
        
        cells.append(.timer(DetailTimerTableViewCell.Info(title: "Expiry", date: lightningInvoice.expiry)))
        
        let settledString = lightningInvoice.settled ? "Settled" : "Unsettled"
        cells.append(.info(DetailTableViewCell.Info(title: "Settled", data: settledString)))
        
        if let settleDate = lightningInvoice.settleDate {
            let dateString = DateFormatter.localizedString(from: settleDate, dateStyle: .medium, timeStyle: .short)
            cells.append(.info(DetailTableViewCell.Info(title: "Settled Date", data: dateString)))
        }
        
        detailCells.replace(with: cells)
    }
}
