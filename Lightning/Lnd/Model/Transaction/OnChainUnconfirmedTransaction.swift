//
//  Lightning
//
//  Created by Otto Suess on 12.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation

// we need this to display unconfirmed transactions in the ui. neutrino only notifies us
// about confirmed transactions.
public struct OnChainUnconfirmedTransaction: OnChainTransaction, Equatable, Codable {
    public let id: String
    public let amount: Satoshi
    public let date: Date
    public let fees: Satoshi?
    public var confirmations: Int
    public var destinationAddresses: [BitcoinAddress]
    
    init(id: String, amount: Satoshi, date: Date, destinationAddresses: [BitcoinAddress]) {
        self.id = id
        self.amount = amount
        self.date = date
        self.destinationAddresses = destinationAddresses
        
        fees = nil
        confirmations = 0
    }
}
