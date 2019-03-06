//
//  Lightning
//
//  Created by 0 on 06.03.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import SQLite
import SwiftBTC

struct CreateInvoiceTable {
    let id: String
    let amount: Satoshi?
    let date: Date
    let expiry: Date
    let paymentRequest: String
}

extension CreateInvoiceTable: ZapTable {
    enum Column {
        static let id = Expression<String>("id")
        static let amount = Expression<Satoshi?>("amount")
        static let date = Expression<Date>("date")
        static let expiry = Expression<Date>("expiry")
        static let paymentRequest = Expression<String>("paymentRequest")
    }

    static let table = Table("createInvoiceEvent")

    init(row: Row) {
        id = row[Column.id]
        amount = row[Column.amount]
        date = row[Column.date]
        expiry = row[Column.expiry]
        paymentRequest = row[Column.paymentRequest]
    }

    static func createTable(database: Connection) throws {
        try database.run(table.create(ifNotExists: true) { t in
            t.column(Column.id, primaryKey: true)
            t.column(Column.amount)
            t.column(Column.date)
            t.column(Column.expiry)
            t.column(Column.paymentRequest)
        })
    }

    func insert(database: Connection) throws {
        try database.run(CreateInvoiceTable.table.insert(
            Column.id <- id,
            Column.amount <- amount,
            Column.date <- date,
            Column.expiry <- expiry,
            Column.paymentRequest <- paymentRequest)
        )
    }
}
