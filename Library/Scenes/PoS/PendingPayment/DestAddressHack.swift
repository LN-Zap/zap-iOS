//
//  Library
//
//  Created by Otto Suess on 11.01.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import SwiftBTC
import SwiftLnd

/// right now lnd has a bug where unconfirmed txs don't have dest_addresses.
/// thats why we're fetching the tx from a block explorer.
///
/// TODO: remove this hack once the issue is solved.
/// https://github.com/lightningnetwork/lnd/issues/2442
final class OnChainAddressCheck {
    private struct BlockstreamTx: Decodable {
        struct VOut: Decodable {
            let value: Int
            let address: String
            
            enum CodingKeys: String, CodingKey {
                case value
                case address = "scriptpubkey_address"
            }
        }
        
        let txid: String
        let vout: [VOut]
    }
    
    let bitcoinURI: BitcoinURI
    
    init(bitcoinURI: BitcoinURI) {
        self.bitcoinURI = bitcoinURI
    }
    
    func checkTransaction(transaction: Transaction, completion: @escaping () -> Void) {
        if let requiredAmount = bitcoinURI.amount,
            requiredAmount <= transaction.amount,
            let url = URL(string: "https://blockstream.info/\(bitcoinURI.bitcoinAddress.network == .testnet ? "testnet/" : "")api/tx/\(transaction.id)") {
            var count: UInt32 = 0
            
            JSONDownloader.get(from: url) { (result: Result<BlockstreamTx>) in
                if let blockstreamTx = result.value {
                    if blockstreamTx.vout
                        .map({ BitcoinAddress(string: $0.address) })
                        .contains(self.bitcoinURI.bitcoinAddress) {
                            completion()
                    }
                    return
                }
                
                guard count < 10 else { return }
                // try again
                count += 1
                sleep(count)
                self.checkTransaction(transaction: transaction, completion: completion)
            }
        }
    }
}
