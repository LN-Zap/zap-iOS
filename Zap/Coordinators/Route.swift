//
//  Zap
//
//  Created by Otto Suess on 02.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation

// Parses deep links to routes in the app.
enum Route {
    case send(String)
    
    init?(url: URL) {
        guard AddressType.lightningInvoice.isValidAddress(url.absoluteString, network: .testnet) else { return nil } // TODO: use real network
        self = .send(url.absoluteString)
    }
}
