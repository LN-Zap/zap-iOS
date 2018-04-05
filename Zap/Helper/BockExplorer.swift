//
//  Zap
//
//  Created by Otto Suess on 26.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Foundation

enum BlockExplorer {
    case blockchainInfo
    case blockcypher
    
    var localized: String {
        switch self {
        case .blockchainInfo:
            return "blockchain.info"
        case .blockcypher:
            return "blockcypher.com"
        }
    }
    
    func url(network: Network, txid: String) -> URL? {
        switch self {
        case .blockchainInfo:
            let networkId = Settings.network == .mainnet ? "" : "testnet."
            return URL(string: "https://\(networkId)blockchain.info/tx/\(txid)")
        case .blockcypher:
            let networkId = Settings.network == .mainnet ? "btc" : "btc-testnet"
            return URL(string: "https://live.blockcypher.com/\(networkId)/tx/\(txid)/")
        }
    }
}
