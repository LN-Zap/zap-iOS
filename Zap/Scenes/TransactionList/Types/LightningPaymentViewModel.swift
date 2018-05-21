//
//  Zap
//
//  Created by Otto Suess on 14.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

final class LightningPaymentViewModel: NSObject, TransactionViewModel {
    let detailViewControllerTitle = "Payment Detail"
    
    var id: String {
        return lightningPayment.id
    }
    
    var date: Date {
        return lightningPayment.date
    }
    
    let annotation: Observable<TransactionAnnotation>
    let lightningPayment: LightningPayment
    
    let displayText: String
    let amount: Satoshi
    let time: String
    
    let data = MutableObservableArray<DetailCellType>([])
    
    init(lightningPayment: LightningPayment, annotation: TransactionAnnotation) {
        self.annotation = Observable(annotation)
        self.lightningPayment = lightningPayment
        
        displayText = lightningPayment.paymentHash
        amount = lightningPayment.amount
        time = DateFormatter.localizedString(from: lightningPayment.date, dateStyle: .none, timeStyle: .short)
        
        super.init()
        
        setupInfoArray()
    }
    
    private func setupInfoArray() {
        if let amountString = Settings.primaryCurrency.value.format(satoshis: lightningPayment.amount) {
            data.append(.info(DetailTableViewCell.Info(title: "Amount", data: amountString)))
        }
        
        if let feeString = Settings.primaryCurrency.value.format(satoshis: lightningPayment.fees) {
            data.append(.info(DetailTableViewCell.Info(title: "Fee", data: feeString)))
        }
        
        let dateString = DateFormatter.localizedString(from: lightningPayment.date, dateStyle: .medium, timeStyle: .short)
        data.append(.info(DetailTableViewCell.Info(title: "Date", data: dateString)))
        
        let observableMemo = Observable<String?>(nil)
        annotation
            .observeNext {
                observableMemo.value = $0.customMemo
            }
            .dispose(in: reactive.bag)
        data.append(.memo(DetailMemoTableViewCell.Info(memo: observableMemo, placeholder: lightningPayment.paymentHash)))
    }
}
