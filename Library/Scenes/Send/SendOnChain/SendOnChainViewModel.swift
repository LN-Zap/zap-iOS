//
//  Zap
//
//  Created by Otto Suess on 06.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import BTCUtil
import Foundation
import Lightning

final class SendOnChainViewModel {
    private let lightningService: LightningService
    let address: String
    let validRange: ClosedRange<Satoshi>
    
    var amount: Satoshi = 0
    
    init(lightningService: LightningService, address: String) {
        self.lightningService = lightningService
        self.address = address
        
        validRange = (0...lightningService.balanceService.onChain.value)
    }

    func send(callback: @escaping (Result<String>) -> Void) {
        lightningService.transactionService.sendCoins(address: address, amount: amount, callback: callback)
    }
}
