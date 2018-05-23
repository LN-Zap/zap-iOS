//
//  Zap
//
//  Created by Otto Suess on 14.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

private func displayTextForAnnotation(_ annotation: TransactionAnnotation, lightningPayment: LightningPayment) -> String {
    if let customMemo = annotation.customMemo {
        return customMemo
    }
    return lightningPayment.paymentHash
}

final class LightningPaymentViewModel: NSObject, TransactionViewModel {
    let icon = Observable<TransactionIcon>(.lightningPayment)
    
    let detailViewControllerTitle = "Payment Detail"
    
    var id: String {
        return lightningPayment.id
    }
    
    var date: Date {
        return lightningPayment.date
    }
    
    let annotation: Observable<TransactionAnnotation>
    let lightningPayment: LightningPayment
    
    let displayText: Observable<String>
    let amount: Observable<Satoshi?>
    
    let detailCells = MutableObservableArray<DetailCellType>([])
    
    init(lightningPayment: LightningPayment, annotation: TransactionAnnotation) {
        self.annotation = Observable(annotation)
        self.lightningPayment = lightningPayment
        
        displayText = Observable(displayTextForAnnotation(annotation, lightningPayment: lightningPayment))
        amount = Observable(lightningPayment.amount)
        
        super.init()
        
        self.annotation
            .observeNext { [displayText] in
                displayText.value = displayTextForAnnotation($0, lightningPayment: lightningPayment)
            }
            .dispose(in: reactive.bag)
        
        setupInfoArray()
    }
    
    private func setupInfoArray() {
        if let amountString = Settings.primaryCurrency.value.format(satoshis: lightningPayment.amount) {
            detailCells.append(.info(DetailTableViewCell.Info(title: "Amount", data: amountString)))
        }
        
        if let feeString = Settings.primaryCurrency.value.format(satoshis: lightningPayment.fees) {
            detailCells.append(.info(DetailTableViewCell.Info(title: "Fee", data: feeString)))
        }
        
        let dateString = DateFormatter.localizedString(from: lightningPayment.date, dateStyle: .medium, timeStyle: .short)
        detailCells.append(.info(DetailTableViewCell.Info(title: "Date", data: dateString)))
        
        let observableMemo = Observable<String?>(nil)
        annotation
            .observeNext {
                observableMemo.value = $0.customMemo
            }
            .dispose(in: reactive.bag)
        detailCells.append(.memo(DetailMemoTableViewCell.Info(memo: observableMemo, placeholder: lightningPayment.paymentHash)))
    }
}
