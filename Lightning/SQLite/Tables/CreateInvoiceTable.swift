//
//  Lightning
//
//  Created by 0 on 06.03.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import SQLite
import SwiftBTC
import SwiftLnd

struct CreateInvoiceTable {
    let id: String
    let amount: Satoshi?
    let date: Date
    let expiry: Date
    let paymentRequest: String
    let state: Invoice.State
}

extension CreateInvoiceTable: ZapTable {
    enum Column {
        static let id = Expression<String>("id")
        static let amount = Expression<Satoshi?>("amount")
        static let date = Expression<Date>("date")
        static let expiry = Expression<Date>("expiry")
        static let paymentRequest = Expression<String>("paymentRequest")
        static let state = Expression<Int>("state")
    }

    static let table = Table("createInvoiceEvent")

    init?(row: Row) {
        guard let state = Invoice.State(rawValue: row[Column.state]) else { return nil }

        id = row[Column.id]
        amount = row[Column.amount]
        date = row[Column.date]
        expiry = row[Column.expiry]
        paymentRequest = row[Column.paymentRequest]
        self.state = state
    }

    static func createTable(database: Connection) throws {
        try database.run(table.create { t in
            t.column(Column.id, primaryKey: true)
            t.column(Column.amount)
            t.column(Column.date)
            t.column(Column.expiry)
            t.column(Column.paymentRequest)
            t.column(Column.state)
        })
    }

    func insert(database: Connection) throws {
        try database.run(CreateInvoiceTable.table.insert(
            or: .replace,
            Column.id <- id,
            Column.amount <- amount,
            Column.date <- date,
            Column.expiry <- expiry,
            Column.paymentRequest <- paymentRequest,
            Column.state <- state.rawValue)
        )
    }
}
