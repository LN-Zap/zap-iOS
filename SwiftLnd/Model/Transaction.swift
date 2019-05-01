//
//  Lightning
//
//  Created by Otto Suess on 08.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftBTC

public struct Transaction: Equatable {
    public let id: String
    public let amount: Satoshi
    public let date: Date
    public let fees: Satoshi?
    public let destinationAddresses: [BitcoinAddress]
    public let blockHeight: Int?
}

extension Transaction {
    init(transaction: Lnrpc_Transaction) {
        id = transaction.txHash
        amount = Satoshi(transaction.amount)
        date = Date(timeIntervalSince1970: TimeInterval(transaction.timeStamp))
        fees = Satoshi(transaction.totalFees)
        destinationAddresses = transaction.destAddresses.compactMap { BitcoinAddress(string: $0) }
        blockHeight = transaction.blockHeight == 0 ? nil : Int(transaction.blockHeight)
    }
}
