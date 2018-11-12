//
//  Zap
//
//  Created by Otto Suess on 26.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import SwiftBTC

enum BlockExplorerError: Error {
    case unsupportedNetwork
}

enum BlockExplorer: String, Codable, CaseIterable {
    enum CodeType {
        case address
        case transactionId
    }
    
    case blockcypher
    case blockstream
    case smartbit
    case yogh
    case OXT
    
    var localized: String {
        switch self {
        case .blockcypher:
            return "BlockCypher"
        case .blockstream:
            return "Blockstream"
        case .smartbit:
            return "Smartbit"
        case .yogh:
            return "Blockchain Reader (Yogh)"
        case .OXT:
            return "OXT"
        }
    }
    
    func url(network: Network, code: String, type: CodeType) throws -> URL? {
        switch type {
        case .address:
            return try url(network: network, address: code)
        case .transactionId:
            return try url(network: network, transactionId: code)
        }
    }
    
    private func url(network: Network, transactionId: String) throws -> URL? {
        switch self {
        case .blockcypher:
            let networkId = network == .mainnet ? "btc" : "btc-testnet"
            return URL(string: "https://live.blockcypher.com/\(networkId)/tx/\(transactionId)/")
        case .blockstream:
            let networkId = network == .mainnet ? "tx" : "testnet/tx"
            return URL(string: "https://blockstream.info/\(networkId)/\(transactionId)")
        case .smartbit:
            let networkId = network == .mainnet ? "www" : "testnet"
            return URL(string: "https://\(networkId).smartbit.com.au/tx/\(transactionId)")
        case .yogh:
            guard network == .mainnet else { throw BlockExplorerError.unsupportedNetwork }
            return URL(string: "http://srv1.yogh.io/#tx:id:\(transactionId)")
        case .OXT:
            guard network == .mainnet else { throw BlockExplorerError.unsupportedNetwork }
            return URL(string: "https://m.oxt.me/transaction/\(transactionId)")
        }
    }
    
    private func url(network: Network, address: String) throws -> URL? {
        switch self {
        case .blockcypher:
            let networkId = network == .mainnet ? "btc" : "btc-testnet"
            return URL(string: "https://live.blockcypher.com/\(networkId)/address/\(address)/")
        case .blockstream:
            let networkId = network == .mainnet ? "address" : "testnet/address"
            return URL(string: "https://blockstream.info/\(networkId)/\(address)")
        case .smartbit:
            let networkId = network == .mainnet ? "www" : "testnet"
            return URL(string: "https://\(networkId).smartbit.com.au/address/\(address)")
        case .yogh:
            guard network == .mainnet else { throw BlockExplorerError.unsupportedNetwork }
            return URL(string: "http://srv1.yogh.io/#addr:id:\(address)")
        case .OXT:
            guard network == .mainnet else { throw BlockExplorerError.unsupportedNetwork }
            return URL(string: "https://oxt.me/transaction/\(address)")
        }
    }
}
