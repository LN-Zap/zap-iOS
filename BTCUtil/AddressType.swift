//
//  BTCUtil
//
//  Created by Otto Suess on 05.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

public enum AddressType {
    case lightningInvoice
    case lightningNode
    case bitcoinAddress
    
    public func isValidAddress(_ string: String, network: Network) -> Bool {
        switch self {
        case .lightningInvoice:
            return isLightningInvoice(string, network: network)
        case .lightningNode:
            return isLightningNode(string)
        case .bitcoinAddress:
            return isBitcoinAddress(string, network: network)
        }
    }
    
    private func isLightningInvoice(_ string: String, network: Network) -> Bool {
        var string = string
        let prefix = "lightning:"
        if string.starts(with: prefix) {
            string = String(string.dropFirst(prefix.count))
        }
        
        return Bolt11.isValid(string, network: network)
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
    
    private func isBitcoinAddress(_ string: String, network: Network) -> Bool {
        var string = string
        let prefix = "bitcoin:"
        if string.starts(with: prefix) {
            string = String(string.dropFirst(prefix.count))
        }
        
        if let address = BitcoinAddress(string: string) {
            switch (address.type, network) {
            case (.pubkeyHash, .mainnet), (.scriptHash, .mainnet),
                 (.testnetPubkeyHash, .testnet), (.testnetScriptHash, .testnet):
                return true
            default:
                return false
            }
        } else if let (humanReadablePart, _) = Bech32.decode(string) {
            switch network {
            case .testnet:
                return humanReadablePart.lowercased() == "tb"
            case .mainnet:
                return humanReadablePart.lowercased() == "bc"
            }
        }
        
        return false
    }
}
