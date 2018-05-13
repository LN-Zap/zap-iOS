//
//  Zap
//
//  Created by Otto Suess on 06.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

final class SendOnChainViewModel {
    private let viewModel: ViewModel
    let address: String
    let validRange: ClosedRange<Satoshi>
    
    var amount: Satoshi = 0
    
    init(viewModel: ViewModel, address: String) {
        self.viewModel = viewModel
        self.address = address
        
        validRange = (0...viewModel.balance.value)
    }

    func send(completion: @escaping () -> Void) {
        viewModel.sendCoins(address: address, amount: amount, completion: completion)
    }
}
