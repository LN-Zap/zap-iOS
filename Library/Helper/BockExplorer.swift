//
//  Zap
//
//  Created by Otto Suess on 26.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Foundation

enum BlockExplorerError: Error {
    case unsupportedNetwork
}

enum BlockExplorer: String, Codable {
    enum CodeType {
        case address
        case transactionId
    }
    
    case blockcypher
    case smartbit
    case yogh
    case OXT
    
    static let all: [BlockExplorer] = [.blockcypher, .smartbit, .yogh, .OXT]
    
    var localized: String {
        switch self {
        case .blockcypher:
            return "BlockCypher"
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
