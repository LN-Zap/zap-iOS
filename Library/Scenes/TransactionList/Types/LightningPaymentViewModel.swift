//
//  Zap
//
//  Created by Otto Suess on 14.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation
import Lightning
import SwiftLnd

final class LightningPaymentViewModel: TransactionViewModel {
    let lightningPayment: LightningPayment
    
    init(lightningPayment: LightningPayment, annotation: TransactionAnnotation) {
        self.lightningPayment = lightningPayment

        let displayTextString = LightningPaymentViewModel.displayTextForAnnotation(annotation, lightningPayment: lightningPayment)
        
        super.init(transaction: lightningPayment, annotation: annotation, displayText: displayTextString, amount: lightningPayment.amount, icon: .lightningPayment)
                        
        self.annotation
            .map { LightningPaymentViewModel.displayTextForAnnotation($0, lightningPayment: lightningPayment) }
            .feedNext(into: displayText)
            .observeNext { _ in }
            .dispose(in: reactive.bag)
    }
    
    private static func displayTextForAnnotation(_ annotation: TransactionAnnotation, lightningPayment: LightningPayment) -> String {
        if let customMemo = annotation.customMemo, customMemo != "" {
            return customMemo
        }
        return lightningPayment.paymentHash
    }
}
