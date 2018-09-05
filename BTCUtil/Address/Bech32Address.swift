//
//  BTCUtil
//
//  Created by Otto Suess on 22.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

private extension Network {
    var bech32Prefix: String {
        switch self {
        case .testnet:
            return "tb"
        case .mainnet:
            return "bc"
        }
    }
}

struct Bech32Address {
    let string: String
    let network: Network
    
    init?(string: String) {
        guard let (humanReadablePart, _) = Bech32.decode(string) else { return nil }
        
        if humanReadablePart.lowercased() == Network.testnet.bech32Prefix {
            network = .testnet
        } else if humanReadablePart.lowercased() == Network.mainnet.bech32Prefix {
            network = .mainnet
        } else {
            return nil
        }
        
        self.string = string
        
        guard self.decode() != nil else { return nil }
    }
    
    init?(network: Network, witnessVersion: Int, witnessProgram: Data) {
        guard let converted = witnessProgram.convertBits(fromBits: 8, toBits: 5, pad: true) else { return nil }
        let data = Data([UInt8(witnessVersion)]) + converted
        self.network = network
        self.string = Bech32.encode(humanReadablePart: network.bech32Prefix, data: data)
    }
    
    func decode() -> (version: Int, program: Data)? {
        guard let dec = Bech32.decode(string) else { return nil }
        
        if dec.humanReadablePart != network.bech32Prefix || dec.data.count < 1 || dec.data[0] > 16 {
            return nil
        }
        guard let res = dec.data.advanced(by: 1).convertBits(fromBits: 5, toBits: 8, pad: false) else {
            return nil
        }
        if res.count < 2 || res.count > 40 {
            return nil
        }
        if dec.data[0] == 0 && res.count != 20 && res.count != 32 {
            return nil
        }
        return (version: Int(dec.data[0]), program: res)
    }
}
