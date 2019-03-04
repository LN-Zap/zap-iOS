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

/// Includes all unsettled invoices.
public struct CreateInvoiceEvent: Equatable, DateProvidingEvent {
    public let id: String
    public let memo: String?
    public let amount: Satoshi?
    public let date: Date
    public let expiry: Date
    public let paymentRequest: String

    public var isExpired: Bool {
        return expiry < Date()
    }
}

extension CreateInvoiceEvent {
    init(invoice: Invoice) {
        id = invoice.id
        memo = invoice.memo
        amount = invoice.amount
        date = invoice.date
        expiry = invoice.expiry
        paymentRequest = invoice.paymentRequest
    }
}

// MARK: - Persistence
extension CreateInvoiceEvent {
    private enum Column {
        static let id = Expression<String>("id")
        static let memo = Expression<String?>("memo")
        static let amount = Expression<Satoshi?>("amount")
        static let date = Expression<Date>("date")
        static let expiry = Expression<Date>("expiry")
        static let paymentRequest = Expression<String>("paymentRequest")
    }

    private static let table = Table("createInvoiceEvent")

    init(row: Row) {
        id = row[Column.id]
        memo = row[Column.memo]
        amount = row[Column.amount]
        date = row[Column.date]
        expiry = row[Column.expiry]
        paymentRequest = row[Column.paymentRequest]
    }

    static func createTable(database: Connection) throws {
        try database.run(table.create(ifNotExists: true) { t in
            t.column(Column.id, primaryKey: true)
            t.column(Column.memo)
            t.column(Column.amount)
            t.column(Column.date)
            t.column(Column.expiry)
            t.column(Column.paymentRequest)
        })
    }

    func insert(database: Connection) throws {
        var memo = self.memo
        if memo == "" {
            memo = nil
        }

        try database.run(CreateInvoiceEvent.table.insert(
            Column.id <- id,
            Column.memo <- memo,
            Column.amount <- amount,
            Column.date <- date,
            Column.expiry <- expiry,
            Column.paymentRequest <- paymentRequest)
        )
    }

    public static func events(database: Connection) throws -> [CreateInvoiceEvent] {
        return try database.prepare(CreateInvoiceEvent.table)
            .map(CreateInvoiceEvent.init)
    }
}
