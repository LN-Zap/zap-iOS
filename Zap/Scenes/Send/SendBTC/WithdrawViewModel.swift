//
//  Zap
//
//  Created by Otto Suess on 06.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

final class WithdrawViewModel: AmountInputtable {
    let amountString = Observable<String?>(nil)
    let isAmountValid = Observable(true)

    private let viewModel: ViewModel
    
    let address: String
    
    init(viewModel: ViewModel, address: String) {
        self.viewModel = viewModel
        self.address = address
    }
    
    func updateAmount(_ amount: String?) {
        amountString.value = amount
        if amount != nil {
            isAmountValid.value = satoshis <= viewModel.balance.value
        }
    }
    
    func send(completion: @escaping () -> Void) {
        viewModel.sendCoins(address: address, amount: satoshis, completion: completion)
    }
}
