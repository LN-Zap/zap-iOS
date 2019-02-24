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
 Includes all Payments.
 Inlcudes invoices that have been settled.
 */
public struct LightningPaymentEvent: Equatable, DateProvidingEvent, AmountProvidingEvent {
    public let paymentHash: String
    public let memo: String?
    public let amount: Satoshi // amount + optional fees
    public let fee: Satoshi
    public let date: Date
    public let node: ConnectedNode?
}

extension LightningPaymentEvent {
    init(payment: Payment, memo: String?, node: ConnectedNode?) {
        paymentHash = payment.paymentHash
        self.memo = memo
        amount = payment.amount
        fee = payment.fees
        date = payment.date
        self.node = node ?? ConnectedNode(pubKey: payment.destination, alias: nil, color: nil)
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
    private enum Column {
        static let paymentHash = Expression<String>("paymentHash")
        static let memo = Expression<String?>("memo")
        static let amount = Expression<Satoshi>("amount")
        static let fee = Expression<Satoshi>("fee")
        static let date = Expression<Date>("date")
        static let destination = Expression<String?>("destination")
    }

    private static let table = Table("lightningPaymentEvent")

    init(row: Row) {
        paymentHash = row[Column.paymentHash]
        if let memo = row[Column.memo],
            !memo.isEmpty {
            self.memo = memo
        } else {
            memo = nil
        }
        amount = row[Column.amount]
        fee = row[Column.fee]
        date = row[Column.date]

        if (try? row.get(ConnectedNode.Column.pubKey)) != nil {
            node = ConnectedNode(row: row)
        } else if let destination = row[Column.destination] {
            node = ConnectedNode(pubKey: destination, alias: nil, color: nil)
        } else {
            node = nil
        }
    }

    static func createTable(database: Connection) throws {
        try database.run(table.create(ifNotExists: true) { t in
            t.column(Column.paymentHash, primaryKey: true)
            t.column(Column.memo)
            t.column(Column.amount)
            t.column(Column.fee)
            t.column(Column.date)
            t.column(Column.destination)
        })
    }

    func insert(database: Connection) throws {
        try database.run(LightningPaymentEvent.table.insert(
            Column.paymentHash <- paymentHash,
            Column.memo <- memo,
            Column.amount <- amount,
            Column.fee <- fee,
            Column.date <- date,
            Column.destination <- node?.pubKey)
        )
    }

    public static func events(database: Connection) throws -> [LightningPaymentEvent] {
        let query = table
            .join(.leftOuter, ConnectedNode.table, on: ConnectedNode.Column.pubKey == table[Column.destination])
        return try database.prepare(query)
            .map(LightningPaymentEvent.init)
    }

    public static func contains(database: Connection, paymentHash: String) throws -> Bool {
        let query = table.filter(Column.paymentHash == paymentHash)
        return try database.pluck(query) != nil
    }
}
