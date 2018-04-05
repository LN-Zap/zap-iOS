//
//  BTCUtil
//
//  Created by Otto Suess on 28.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

enum Bolt11 {
    static func isValid(_ string: String, network: Network) -> Bool {
        guard let (humanReadablePart, _) = Bech32.decode(string, limit: false) else { return false }
        
        switch network {
        case .testnet:
            return humanReadablePart.hasPrefix("lntb")
        case .mainnet:
            return humanReadablePart.hasPrefix("lnbc")
        }
    }
}
