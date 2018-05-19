//
//  Zap
//
//  Created by Otto Suess on 14.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

enum LightningInvoiceState {
    case settled
    case unsettled
    case expired
}

final class LightningInvoiceViewModel: NSObject, TransactionViewModel {
    let detailViewControllerTitle = "Invoice Detail"
    
    var id: String {
        return lightningInvoice.id
    }
    
    var date: Date {
        return lightningInvoice.date
    }
    
    let annotation: Observable<TransactionAnnotation>
    let lightningInvoice: LightningInvoice
    
    let displayText: String
    let amount: Satoshi
    let time: String
    
    let data = MutableObservableArray<DetailCellType>([])
    
    let state: Observable<LightningInvoiceState>
    
    init(lightningInvoice: LightningInvoice, annotation: TransactionAnnotation) {
        self.annotation = Observable(annotation)
        self.lightningInvoice = lightningInvoice
        
        if !lightningInvoice.memo.isEmpty {
            displayText = lightningInvoice.memo
        } else {
            displayText = lightningInvoice.paymentRequest
        }
        
        amount = lightningInvoice.amount
        time = DateFormatter.localizedString(from: lightningInvoice.date, dateStyle: .none, timeStyle: .short)
        
        if lightningInvoice.settled {
            state = Observable(.settled)
        } else if lightningInvoice.expiry < Date() {
            state = Observable(.expired)
        } else {
            state = Observable(.unsettled)
        }
        
        super.init()
        
        setupInfoArray()
    }
    
    private func setupInfoArray() {
        if lightningInvoice.expiry > Date() {
            data.append(.qrCode(lightningInvoice.paymentRequest))
        }
        
        if let amountString = lightningInvoice.amount > 0 ? Settings.primaryCurrency.value.format(satoshis: lightningInvoice.amount) : "Unspecified" {
            data.append(.info(DetailTableViewCell.Info(title: "Amount", data: amountString)))
        }
        
        let dateString = DateFormatter.localizedString(from: lightningInvoice.date, dateStyle: .medium, timeStyle: .short)
        data.append(.info(DetailTableViewCell.Info(title: "Created", data: dateString)))
        
        data.append(.info(DetailTableViewCell.Info(title: "Payment Request", data: lightningInvoice.paymentRequest)))
        
        let observableMemo = Observable<String?>(nil)
        annotation
            .observeNext {
                observableMemo.value = $0.customMemo
            }
            .dispose(in: reactive.bag)
        data.append(.memo(DetailMemoTableViewCell.Info(memo: observableMemo, placeholder: lightningInvoice.memo)))
        
        data.append(.timer(DetailTimerTableViewCell.Info(title: "Expiry", date: lightningInvoice.expiry)))
        
        let settledString = lightningInvoice.settled ? "Settled" : "Unsettled"
        data.append(.info(DetailTableViewCell.Info(title: "Settled", data: settledString)))
        
        if let settleDate = lightningInvoice.settleDate {
            let dateString = DateFormatter.localizedString(from: settleDate, dateStyle: .medium, timeStyle: .short)
            data.append(.info(DetailTableViewCell.Info(title: "Settled Date", data: dateString)))
        }
    }
}
