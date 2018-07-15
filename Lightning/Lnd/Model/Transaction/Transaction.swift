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
}

extension Transaction {
    public func isTransactionEqual(to transaction: Transaction) -> Bool {
        if let lhs = self as? OnChainConfirmedTransaction, let rhs = transaction as? OnChainConfirmedTransaction {
            return lhs == rhs
        } else if let lhs = self as? LightningInvoice, let rhs = transaction as? LightningInvoice {
            return lhs == rhs
        } else if let lhs = self as? LightningPayment, let rhs = transaction as? LightningPayment {
            return lhs == rhs
        } else if let lhs = self as? OnChainUnconfirmedTransaction, let rhs = transaction as? OnChainUnconfirmedTransaction {
            return lhs == rhs
        } else {
            return false
        }
    }
}
