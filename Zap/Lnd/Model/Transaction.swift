//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Foundation
import LightningRpc

struct Transaction: Equatable {
    let amount: Satoshi
    let timeStamp: Double
    let fees: Satoshi

    let isOnChain: Bool
    let confirmations: Int?
    
    let displayText: String
}

// MARK: - OnChainTransaction

extension Transaction {
    init(transaction: LightningRpc.Transaction) {
        amount = Satoshi(value: transaction.amount)
        timeStamp = Double(transaction.timeStamp)
        fees = Satoshi(value: transaction.totalFees)
        isOnChain = true
        confirmations = Int(transaction.numConfirmations)
        
        displayText = transaction.destAddressesArray.firstObject as? String ?? ""
    }

    init(payment: LightningRpc.Payment) {
        amount = Satoshi(value: -payment.value)
        timeStamp = Double(payment.creationDate)
        fees = Satoshi(value: payment.fee)
        isOnChain = false
        confirmations = nil
        
        displayText = payment.paymentHash
    }
}
