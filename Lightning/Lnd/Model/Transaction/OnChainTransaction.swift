//
//  Lightning
//
//  Created by Otto Suess on 08.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation

public struct OnChainTransaction: Transaction, Equatable {
    public let id: String
    public let amount: Satoshi
    public let date: Date
    public let fees: Satoshi
    public let confirmations: Int
    public let firstDestinationAddress: String
}

extension OnChainTransaction {
    init(transaction: Lnrpc_Transaction) {
        id = transaction.txHash
        amount = Satoshi(value: transaction.amount)
        date = Date(timeIntervalSince1970: TimeInterval(transaction.timeStamp))
        fees = Satoshi(value: transaction.totalFees)
        confirmations = Int(transaction.numConfirmations)
        firstDestinationAddress = transaction.destAddresses.first ?? ""
    }
}
