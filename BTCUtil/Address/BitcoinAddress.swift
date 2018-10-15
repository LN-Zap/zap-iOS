//
//  BTCUtil
//
//  Created by Otto Suess on 22.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

private extension Network {
    var pubKeyHashAddrID: Int {
        switch self {
        case .testnet:
            return 0x6f // starts with m or n
        case .mainnet:
            return 0x00 // starts with 1
        }
    }
    
    var scriptHashAddrID: Int {
        switch self {
        case .testnet:
            return 0xc4 // starts with 2
        case .mainnet:
            return 0x05 // starts with 3
        }
    }
}

/// Represents p2pkh, p2sh & bech32 bitcoin addresses
public struct BitcoinAddress: Codable, Equatable, Hashable {
    public enum AddressType {
        case p2pkh
        case p2sh
        case bech32
    }
    
    public let string: String
    public let network: Network
    public let type: AddressType
    
    public init?(witnessPubKeyHash: Data, network: Network) {
        guard
            witnessPubKeyHash.count == 20,
            let address = Bech32Address(network: network, witnessVersion: 0x00, witnessProgram: witnessPubKeyHash)?.string
            else { return nil }
        
        self.network = network
        self.string = address
        self.type = .bech32
    }
    
    public init?(witnessScriptHash: Data, network: Network) {
        guard
            witnessScriptHash.count == 32,
            let address = Bech32Address(network: network, witnessVersion: 0x00, witnessProgram: witnessScriptHash)?.string
            else { return nil }
        
        self.network = network
        self.string = address
        self.type = .bech32
    }
    
    public init?(pubKeyHash: Data, network: Network) {
        guard pubKeyHash.count == 20 else { return nil }
        self.network = network
        self.type = .p2pkh
        self.string = Base58.checkEncode(pubKeyHash, version: network.pubKeyHashAddrID)
    }
    
    public init?(scriptHashFromHash: Data, network: Network) {
        self.network = network
        self.type = .p2sh
        self.string = Base58.checkEncode(scriptHashFromHash, version: network.scriptHashAddrID)
    }
    
    public init?(string: String) {
        if let legacyAddress = LegacyBitcoinAddress(string: string) {
            switch legacyAddress.type {
            case .pubkeyHash:
                type = .p2pkh
            case .scriptHash:
                type = .p2sh
            default:
                return nil
            }
            
            network = legacyAddress.network
        } else if let bech32Address = Bech32Address(string: string) {
            type = .bech32

            network = bech32Address.network
        } else {
            return nil
        }
        
        self.string = string
    }
    
    // MARK: Codable
    
    enum CodingKeys: String, CodingKey {
        case string
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        string = try values.decode(String.self, forKey: .string)
        
        guard let address = BitcoinAddress(string: string) else {
            throw DecodingError.dataCorruptedError(in: try decoder.singleValueContainer(), debugDescription: "Invalid Bitcoin Address")
        }
        
        self.network = address.network
        self.type = address.type
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(string, forKey: .string)
    }
}
