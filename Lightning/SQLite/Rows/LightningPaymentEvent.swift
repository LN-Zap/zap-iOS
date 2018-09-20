//
//  Lightning
//
//  Created by Otto Suess on 12.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation
import SQLite
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
    public let destination: String?
}

extension LightningPaymentEvent {
    init(payment: Payment, memo: String?) {
        paymentHash = payment.paymentHash
        self.memo = memo
        amount = payment.amount
        fee = payment.fees
        date = payment.date
        destination = payment.destination
    }
    
    init(invoice: Invoice) {
        paymentHash = invoice.id
        memo = invoice.memo
        amount = invoice.amount
        fee = 0
        date = invoice.date
        destination = nil
    }
}

// MARK: - Persistance
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
        memo = row[Column.memo]
        amount = row[Column.amount]
        fee = row[Column.fee]
        destination = row[Column.destination]
        date = row[Column.date]
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
            Column.date <- date)
        )
    }
    
    public static func events(database: Connection) throws -> [LightningPaymentEvent] {
        return try database.prepare(LightningPaymentEvent.table)
            .map(LightningPaymentEvent.init)
    }
}
