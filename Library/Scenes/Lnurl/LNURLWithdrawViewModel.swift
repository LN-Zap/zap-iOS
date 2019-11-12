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

final class LNURLWithdrawViewModel {
    let request: LNURLWithdrawRequest
    let lightningService: LightningService
    
    let selectedAmount: Observable<Satoshi>
    
    let maxWithdrawable: Satoshi
    let minWithdrawable: Satoshi
    
    var description: String {
        return request.description
    }
    
    var domain: String? {
        return request.domain?.host
    }
    
    init(request: LNURLWithdrawRequest, lightningService: LightningService) {
        self.request = request
        self.lightningService = lightningService
        
        minWithdrawable = request.minWithdrawable
        maxWithdrawable = request.maxWithdrawable
        selectedAmount = Observable(request.maxWithdrawable)
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
