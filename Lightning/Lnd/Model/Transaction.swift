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

public struct LightningPayment: Transaction, Equatable {
    public let id: String
    public let amount: Satoshi
    public let date: Date
    public let fees: Satoshi
    public let paymentHash: String
}

extension LightningPayment {
    init(payment: Lnrpc_Payment) {
        id = payment.paymentHash
        amount = Satoshi(value: -payment.value)
        date = Date(timeIntervalSince1970: TimeInterval(payment.creationDate))
        fees = Satoshi(value: payment.fee)
        paymentHash = payment.paymentHash
    }
}
