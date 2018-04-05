//
//  Zap
//
//  Created by Otto Suess on 06.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

final class WithdrawViewModel {
    private let viewModel: ViewModel
    
    let sendEnabled = Observable(false)
    let address: String
    var amount = Observable<Satoshi>(100)
    
    init(viewModel: ViewModel, address: String) {
        self.viewModel = viewModel
        self.address = address
    }
    
    func send() {
        _ = viewModel.sendCoins(address: address, amount: amount.value)
    }
    
    func selectAll() {
        amount.value = viewModel.balance.value
    }
}
