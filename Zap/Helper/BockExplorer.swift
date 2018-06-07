//
//  Zap
//
//  Created by Otto Suess on 26.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Foundation

enum BlockExplorer {
    case blockcypher
    
    var localized: String {
        switch self {
        case .blockcypher:
            return "blockcypher.com"
        }
    }
    
    func url(network: Network, txid: String) -> URL? {
        switch self {
        case .blockcypher:
            let networkId = network == .mainnet ? "btc" : "btc-testnet"
            return URL(string: "https://live.blockcypher.com/\(networkId)/tx/\(txid)/")
        }
    }
}
