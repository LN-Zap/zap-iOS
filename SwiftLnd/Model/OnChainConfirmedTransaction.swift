//
//  Lightning
//
//  Created by Otto Suess on 08.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation

public struct OnChainConfirmedTransaction: Equatable {
    public let id: String
    public let amount: Satoshi
    public let date: Date
    public let fees: Satoshi?
    public let confirmations: Int
    public let destinationAddresses: [BitcoinAddress]
    public let blockHeight: Int
}

extension OnChainConfirmedTransaction {
    init(transaction: Lnrpc_Transaction) {
        id = transaction.txHash
        amount = Satoshi(transaction.amount)
        date = Date(timeIntervalSince1970: TimeInterval(transaction.timeStamp))
        fees = Satoshi(transaction.totalFees)
        confirmations = Int(transaction.numConfirmations)
        destinationAddresses = transaction.destAddresses.compactMap { BitcoinAddress(string: $0) }
        blockHeight = Int(transaction.blockHeight)
    }
}
