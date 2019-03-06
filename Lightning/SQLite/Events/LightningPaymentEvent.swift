//
//  Lightning
//
//  Created by Otto Suess on 12.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SQLite
import SwiftBTC
import SwiftLnd

/*
 Includes all Payments (outgoing lightning transactions).
 Inlcudes invoices that have been settled (incoming lightning transactions).
 */
public struct LightningPaymentEvent: Equatable, DateProvidingEvent, AmountProvidingEvent {
    public let paymentHash: String
    public let memo: String?
    public let amount: Satoshi // amount + optional fees
    public let fee: Satoshi
    public let date: Date
    public let node: ConnectedNodeTable?
}

extension LightningPaymentEvent {
    init(payment: Payment, memo: String?, node: ConnectedNodeTable?) {
        paymentHash = payment.paymentHash
        self.memo = memo
        amount = payment.amount
        fee = payment.fees
        date = payment.date
        self.node = node ?? ConnectedNodeTable(pubKey: payment.destination, alias: nil, color: nil)
    }

    init(invoice: Invoice) {
        paymentHash = invoice.id
        memo = invoice.memo
        amount = invoice.amount
        fee = 0
        date = invoice.date
        node = nil
    }
}

// MARK: - Persistence
extension LightningPaymentEvent {
    func insert(database: Connection) throws {
        try LightningPaymentTable(paymentHash: paymentHash, amount: amount, fee: fee, date: date, destination: node?.pubKey).insert(database: database)
        try MemoTable(id: paymentHash, text: memo)?.insert(database: database)
    }

    private init(row: Row) {
        let lightningPayment = LightningPaymentTable(row: row)

        paymentHash = lightningPayment.paymentHash
        amount = lightningPayment.amount
        fee = lightningPayment.fee
        date = lightningPayment.date

        if let node = ConnectedNodeTable(row: row) {
            self.node = node
        } else if let destination = lightningPayment.destination {
            node = ConnectedNodeTable(pubKey: destination, alias: nil, color: nil)
        } else {
            node = nil
        }
        memo = MemoTable(row: row)?.text
    }

    public static func events(database: Connection) throws -> [LightningPaymentEvent] {
        let query = LightningPaymentTable.table
            .join(.leftOuter, ConnectedNodeTable.table, on: ConnectedNodeTable.Column.pubKey == LightningPaymentTable.table[LightningPaymentTable.Column.destination])
            .join(.leftOuter, MemoTable.table, on: MemoTable.Column.id == LightningPaymentTable.table[LightningPaymentTable.Column.paymentHash])
        return try database.prepare(query)
            .map(LightningPaymentEvent.init)
    }

    public static func contains(database: Connection, paymentHash: String) throws -> Bool {
        let query = LightningPaymentTable.table.filter(LightningPaymentTable.Column.paymentHash == paymentHash)
        return try database.pluck(query) != nil
    }
}
