//
//  BTCUtil
//
//  Created by Otto Suess on 22.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

public struct BitcoinAddress: Codable, Equatable {
    public enum AddressType {
        case p2pkh
        case p2sh
        case bech32
    }
    
    public let string: String
    public let network: Network
    public let type: AddressType
    
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
