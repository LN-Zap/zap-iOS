//
//  Zap
//
//  Created by Otto Suess on 06.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning
import SwiftLnd

final class LightningInvoiceDetailViewModel: NSObject, DetailViewModel {
    let detailViewControllerTitle = "scene.transaction_detail.title.lightning_invoice".localized
    let detailCells = MutableObservableArray<DetailCellType>([])
    
    init(lightningInvoice: Invoice, annotation: Observable<TransactionAnnotation>, historyViewModel: HistoryViewModel) {
        super.init()
        
        if lightningInvoice.expiry > Date(),
            let invoiceURI = LightningInvoiceURI(invoice: lightningInvoice) {
            detailCells.append(.qrCode(invoiceURI))
            detailCells.append(.separator)
        }
        
        if let amountString = lightningInvoice.amount > 0 ? Settings.shared.primaryCurrency.value.format(satoshis: lightningInvoice.amount) : "scene.transaction_detail.amount.unspecified_label".localized {
            detailCells.append(.info(DetailTableViewCell.Info(title: "scene.transaction_detail.amount_label".localized, data: amountString)))
            detailCells.append(.separator)
        }
        
        let dateString = DateFormatter.localizedString(from: lightningInvoice.date, dateStyle: .medium, timeStyle: .short)
        detailCells.append(.info(DetailTableViewCell.Info(title: "scene.transaction_detail.created_label".localized, data: dateString)))
        detailCells.append(.separator)
        
        detailCells.append(.info(DetailTableViewCell.Info(title: "scene.transaction_detail.payment_request".localized, data: lightningInvoice.paymentRequest)))
        detailCells.append(.separator)
        
        detailCells.append(DetailCellType.memoCell(transaction: lightningInvoice, annotation: annotation, historyViewModel: historyViewModel, placeholder: lightningInvoice.paymentRequest))
        detailCells.append(.separator)
        
        detailCells.append(.timer(DetailTimerTableViewCell.Info(title: "scene.transaction_detail.expiry_label".localized, date: lightningInvoice.expiry)))
        detailCells.append(.separator)
        
        let settledString = lightningInvoice.settled ? "scene.transaction_detail.settled_state.settled".localized : "scene.transaction_detail.settled_state.unsettled".localized
        detailCells.append(.info(DetailTableViewCell.Info(title: "scene.transaction_detail.settled_label".localized, data: settledString)))
        detailCells.append(.separator)
        
        if let settleDate = lightningInvoice.settleDate {
            let dateString = DateFormatter.localizedString(from: settleDate, dateStyle: .medium, timeStyle: .short)
            detailCells.append(.info(DetailTableViewCell.Info(title: "scene.transaction_detail.settled_date_label".localized, data: dateString)))
            detailCells.append(.separator)
        }
        
        detailCells.append(DetailCellType.hideTransactionCell(transaction: lightningInvoice, annotation: annotation.value, historyViewModel: historyViewModel))
    }
}
