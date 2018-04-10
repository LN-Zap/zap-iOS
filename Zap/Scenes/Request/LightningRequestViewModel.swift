//
//  Zap
//
//  Created by Otto Suess on 07.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

final class LightningRequestViewModel {
    private let maxPaymentAllowed: Satoshi = 4294967
    private let viewModel: ViewModel
    
    let isAmountValid = Observable(true)
    
    var satoshis: Satoshi? {
        guard let amountString = amountString.value else { return nil }
        return Satoshi.from(string: amountString, unit: .bit)
    }
    
    let amountString = Observable<String?>(nil)
    var memo: String?
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    func create(callback: @escaping (String) -> Void) {
        guard let satoshis = satoshis else { return }
        viewModel.addInvoice(amount: satoshis, memo: memo) { result in
            guard let string = result.value else { return }
            callback(string)
        }
    }
    
    func updateAmount(_ amount: String?) {
        amountString.value = amount
        if amount != nil {
            isAmountValid.value = (satoshis ?? 0) <= maxPaymentAllowed
        }
    }
}
