//
//  Lightning
//
//  Created by Otto Suess on 11.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SQLite
import SwiftBTC
import SwiftLnd

/// Gets created when a payment request fails to complete.
public struct FailedPaymentEvent: Equatable, DateProvidingEvent, AmountProvidingEvent {
    public let paymentHash: String
    public let memo: String?
    public let amount: Satoshi
    public let date: Date
    public let expiry: Date
    public let fallbackAddress: BitcoinAddress?
    public let paymentRequest: String
    public let node: LightningNode
}

extension FailedPaymentEvent {
    init(paymentRequest: PaymentRequest, amount: Satoshi) {
        paymentHash = paymentRequest.paymentHash
        memo = paymentRequest.memo
        self.amount = amount
        date = paymentRequest.date
        expiry = paymentRequest.expiryDate
        fallbackAddress = paymentRequest.fallbackAddress
        self.paymentRequest = paymentRequest.raw
        node = LightningNode(pubKey: paymentRequest.destination, alias: nil, color: nil)
    }

    public var isExpired: Bool {
        return expiry < Date()
    }
}

// MARK: - Persistence
extension FailedPaymentEvent {
    init(row: Row) {
        let failedPaymentTable = FailedPaymentTable(row: row)
        paymentHash = failedPaymentTable.paymentHash
        memo = MemoTable(row: row)?.text
        amount = failedPaymentTable.amount
        date = failedPaymentTable.date
        expiry = failedPaymentTable.expiry
        fallbackAddress = failedPaymentTable.fallbackAddress
        paymentRequest = failedPaymentTable.paymentRequest

        if let nodeTable = ConnectedNodeTable(row: row) {
            node = LightningNode(pubKey: nodeTable.pubKey, alias: nodeTable.alias, color: nodeTable.color)
        } else {
            node = LightningNode(pubKey: failedPaymentTable.destination, alias: nil, color: nil)
        }
    }

    func insert(database: Connection) throws {
        try FailedPaymentTable(paymentHash: paymentHash, amount: amount, destination: node.pubKey, date: date, expiry: expiry, fallbackAddress: fallbackAddress, paymentRequest: paymentRequest).insert(database: database)
        try MemoTable(id: paymentHash, text: memo)?.insert(database: database)
    }

    public static func events(database: Connection) throws -> [FailedPaymentEvent] {
        let query = FailedPaymentTable.table
            .join(.leftOuter, ConnectedNodeTable.table, on: ConnectedNodeTable.Column.pubKey == FailedPaymentTable.table[FailedPaymentTable.Column.destination])
            .join(.leftOuter, MemoTable.table, on: MemoTable.Column.id == FailedPaymentTable.table[FailedPaymentTable.Column.paymentHash])
        return try database.prepare(query)
            .map(FailedPaymentEvent.init)
    }
}
