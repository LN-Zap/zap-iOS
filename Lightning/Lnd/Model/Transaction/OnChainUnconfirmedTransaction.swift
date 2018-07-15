//
//  Lightning
//
//  Created by Otto Suess on 12.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation

public struct OnChainUnconfirmedTransaction: OnChainTransaction, Equatable, Codable {
    public let id: String
    public let amount: Satoshi
    public let date: Date
    public let fees: Satoshi?
    public var confirmations: Int
    public var destinationAddress: String
    
    init(id: String, amount: Satoshi, date: Date, destinationAddress: String) {
        self.id = id
        self.amount = amount
        self.date = date
        self.destinationAddress = destinationAddress
        
        fees = nil
        confirmations = 0
    }
}
