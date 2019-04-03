//
//  Lightning
//
//  Created by Otto Suess on 11.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftBTC
import SwiftLnd

/*
 This is any event that transfers bitcoin from one wallet to another.
 Includes transactions, except those resulting from opening or closing channels.
 */
public struct TransactionEvent: Equatable, DateProvidingEvent, AmountProvidingEvent {
    public let txHash: String
    public let amount: Satoshi
    public let fee: Satoshi?
    public let date: Date
    public let destinationAddresses: [BitcoinAddress]
    public let blockHeight: Int?
}

extension TransactionEvent {
    init?(transaction: Transaction) {
        guard transaction.amount != 0 else { return nil }

        txHash = transaction.id
        amount = transaction.amount
        fee = transaction.fees ?? 0
        date = transaction.date
        destinationAddresses = transaction.destinationAddresses
        blockHeight = transaction.blockHeight
    }
}
