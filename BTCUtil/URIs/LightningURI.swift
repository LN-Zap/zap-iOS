//
//  BTCUtil
//
//  Created by Otto Suess on 06.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

public struct LightningURI {
    public let address: String
    public let network: Network
    public let stringValue: String

    public init?(string: String) {
        var string = string
        let prefix = "lightning:"
        if string.starts(with: prefix) {
            string = String(string.dropFirst(prefix.count))
        }
        
        guard let (humanReadablePart, _) = Bech32.decode(string, limit: false) else { return nil }
        
        address = string
        stringValue = string
        
        if humanReadablePart.hasPrefix("lntb") {
            network = .testnet
        } else if humanReadablePart.hasPrefix("lnbc") {
            network = .mainnet
        } else {
            return nil
        }
    }
}
