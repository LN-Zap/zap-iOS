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
    init(row: Row) {
        let createInvoiceTable = CreateInvoiceTable(row: row)
        id = createInvoiceTable.id
        memo = MemoTable(row: row)?.text
        amount = createInvoiceTable.amount
        date = createInvoiceTable.date
        expiry = createInvoiceTable.expiry
        paymentRequest = createInvoiceTable.paymentRequest
    }

    func insert(database: Connection) throws {
        try CreateInvoiceTable(id: id, amount: amount, date: date, expiry: expiry, paymentRequest: paymentRequest).insert(database: database)
        try MemoTable(id: id, text: memo)?.insert(database: database)
    }

    public static func events(database: Connection) throws -> [CreateInvoiceEvent] {
        return try database.prepare(CreateInvoiceTable.table
            .join(.leftOuter, MemoTable.table, on: MemoTable.Column.id == CreateInvoiceTable.table[CreateInvoiceTable.Column.id]))
            .map(CreateInvoiceEvent.init)
    }
}
