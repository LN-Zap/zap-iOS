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
        guard let (humanReadablePart, decoded) = Bech32.decode(string) else { return nil }
        
        if humanReadablePart.lowercased() == "tb" {
            network = .testnet
        } else if humanReadablePart.lowercased() == "bc" {
            network = .mainnet
        } else {
            return nil
        }
        
        self.string = string
        
        if !isValid(decoded: decoded) {
            return nil
        }
    }
    
    private func isValid(decoded: Data) -> Bool {
        if decoded.count < 1 || decoded[0] > 16 {
            return false
        }
        guard let res = decoded.advanced(by: 1).convertBits(fromBits: 5, toBits: 8, pad: false) else {
            return false
        }
        if res.count < 2 || res.count > 40 {
            return false
        }
        if decoded[0] == 0 && res.count != 20 && res.count != 32 {
            return false
        }
        return true
    }
}
