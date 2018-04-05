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
        guard let address = BitcoinAddress(string: string) else { return false }
        
        switch (address.type, network) {
        case (.pubkeyHash, .mainnet), (.scriptHash, .mainnet),
             (.testnetPubkeyHash, .testnet), (.testnetScriptHash, .testnet):
            return true
        default:
            return false
        }
    }
}
