//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Foundation

public protocol Transaction {
    var id: String { get }
    var amount: Satoshi { get }
    var date: Date { get }
    var fees: Satoshi { get }
}

extension Transaction {
    public func isEqual(to transaction: Transaction) -> Bool {
        if let lhs = self as? OnChainTransaction, let rhs = transaction as? OnChainTransaction {
            return lhs == rhs
        } else if let lhs = self as? LightningInvoice, let rhs = transaction as? LightningInvoice {
            return lhs == rhs
        } else if let lhs = self as? LightningPayment, let rhs = transaction as? LightningPayment {
            return lhs == rhs
        } else {
            return false
        }
    }
}
