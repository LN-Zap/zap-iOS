//
//  Library
//
//  Created by 0 on 08.11.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning
import SwiftBTC

public extension Satoshi {
    var floored: Satoshi {
        var value = self
        var result: Decimal = 0
        NSDecimalRound(&result, &value, 0, .down)
        return result
    }
}

final class LNURLWithdrawViewModel {
    let request: LNURLWithdrawRequest
    let lightningService: LightningService
    
    let selectedAmount: Observable<Satoshi>
    
    let maxWithdrawable: Satoshi
    let minWithdrawable: Satoshi
    
    var description: String {
        return request.defaultDescription
    }
    
    init(request: LNURLWithdrawRequest, lightningService: LightningService) {
        self.request = request
        self.lightningService = lightningService
        
        let maxWithdrawable = (request.maxWithdrawable / 1000).floored
        self.maxWithdrawable = maxWithdrawable
        selectedAmount = Observable(maxWithdrawable)
        
        if let minWithdrawable = request.minWithdrawable {
            self.minWithdrawable = (minWithdrawable / 1000).floored
        } else {
            self.minWithdrawable = 1
        }
    }
    
    func withdraw(completion: @escaping (LNURL.LNURLError?) -> Void) {
        LNURL.withdraw(lightningService: lightningService, request: request, amount: selectedAmount.value) { result in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
}
