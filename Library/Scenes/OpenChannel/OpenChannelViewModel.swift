//
//  Zap
//
//  Created by Otto Suess on 10.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import BTCUtil
import Foundation
import Lightning

final class OpenChannelViewModel {
    private let lightningService: LightningService
    private let pubKey: String
    private let host: String
    
    var amount: Satoshi = 0
    
    init?(lightningService: LightningService, address: String) {
        self.lightningService = lightningService
        
        let addressComponents = address.split { ["@", " "].contains(String($0)) }
        guard addressComponents.count == 2 else { return nil }
        
        pubKey = String(addressComponents[0])
        host = String(addressComponents[1])        
    }
    
    func openChannel(completion: @escaping () -> Void) {
        lightningService.channelService.open(pubKey: pubKey, host: host, amount: amount, completion: completion)
    }
}
