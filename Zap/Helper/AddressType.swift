//
//  Zap
//
//  Created by Otto Suess on 26.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

// TODO: remove this, better version in BTCUtil
enum AddressType {
    case lightningInvoice
    case lightningNode
    case bitcoinAddress
    
    func isValidAddress(_ string: String) -> Bool {
        switch self {
        case .lightningInvoice:
            return isLightningInvoice(string)
        case .lightningNode:
            return isLightningNode(string)
        case .bitcoinAddress:
            return isBitcoinAddress(string)
        }
    }
    
    private func isLightningInvoice(_ string: String) -> Bool {
        switch Settings.network {
        case .mainnet:
            return string.starts(with: ["lnbc", "lightning:lnbc"])
        case .testnet:
            return string.starts(with: ["lntb", "lightning:lntb"])
        }
    }
    
    private func isBitcoinAddress(_ string: String) -> Bool {
        switch Settings.network {
        case .mainnet:
            return string.starts(with: ["1", "3", "xpub", "bc"])
        case .testnet:
            return string.starts(with: ["m", "n", "2", "tpub", "tb"])
        }
    }
    
    private func isLightningNode(_ string: String) -> Bool {
        // TODO: should be regex to allow for better tests
        let parts = string
            .split { [":", "@", " "].contains(String($0)) }
            .map { $0.trimmingCharacters(in: .whitespaces) }

        return parts.count >= 2
            && parts.count <= 3
            && parts[0].count == 66
            && parts[0].starts(with: "0")
    }
}
