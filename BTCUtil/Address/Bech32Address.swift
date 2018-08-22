//
//  BTCUtil
//
//  Created by Otto Suess on 22.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

struct Bech32Address {
    let string: String
    let network: Network
    
    init?(string: String) {
        guard let (humanReadablePart, _) = Bech32.decode(string) else { return nil }
        
        if humanReadablePart.lowercased() == "tb" {
            network = .testnet
        } else if humanReadablePart.lowercased() == "bc" {
            network = .mainnet
        } else {
            return nil
        }
        
        self.string = string
    }
}
