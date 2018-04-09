//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Foundation
import LightningRpc

protocol Transaction {
    var id: String { get }
    var amount: Satoshi { get }
    var date: Date { get }
    var fees: Satoshi { get }
}

struct BlockchainTransaction: Transaction, Equatable {
    let id: String
    let amount: Satoshi
    let date: Date
    let fees: Satoshi
    let confirmations: Int
    let firstDestinationAddress: String
    
    init(transaction: LightningRpc.Transaction) {
        id = transaction.txHash
        amount = Satoshi(value: transaction.amount)
        date = Date(timeIntervalSince1970: TimeInterval(transaction.timeStamp))
        fees = Satoshi(value: transaction.totalFees)
        confirmations = Int(transaction.numConfirmations)
        firstDestinationAddress = transaction.destAddressesArray.firstObject as? String ?? ""
    }
}

struct Payment: Transaction, Equatable {
    let id: String
    let amount: Satoshi
    let date: Date
    let fees: Satoshi
    let paymentHash: String

    init(payment: LightningRpc.Payment) {
        id = payment.paymentHash
        amount = Satoshi(value: -payment.value)
        date = Date(timeIntervalSince1970: TimeInterval(payment.creationDate))
        fees = Satoshi(value: payment.fee)
        paymentHash = payment.paymentHash
    }
}
