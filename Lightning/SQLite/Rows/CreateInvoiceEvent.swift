//
//  Lightning
//
//  Created by Otto Suess on 12.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation
import SQLite

/// Includes all unsettled invoices.
struct CreateInvoiceEvent {
    let id: String
    let memo: String?
    let amount: Satoshi?
    let date: Date
    let expiry: Date
    let preimage: String
    let paymentRequest: String
}

// SQL
extension CreateInvoiceEvent {
    private enum Column {
        static let id = Expression<String>("id")
        static let memo = Expression<String?>("memo")
        static let amount = Expression<Satoshi?>("amount")
        static let date = Expression<Date>("date")
        static let expiry = Expression<Date>("expiry")
        static let preimage = Expression<String?>("preimage")
        static let paymentRequest = Expression<String>("paymentRequest")
    }
    
    private static let table = Table("createInvoiceEvent")
    
    static func createTable(connection: Connection) throws {
        try connection.run(table.create(ifNotExists: true) { t in
            t.column(Column.id, primaryKey: true)
            t.column(Column.memo)
            t.column(Column.amount)
            t.column(Column.date)
            t.column(Column.expiry)
            t.column(Column.preimage)
            t.column(Column.paymentRequest)
        })
    }
    
    func insert() throws {
        try SQLiteDataStore.shared.connection.run(CreateInvoiceEvent.table.insert(
            Column.id <- id,
            Column.memo <- memo,
            Column.amount <- amount,
            Column.date <- date,
            Column.expiry <- expiry,
            Column.preimage <- preimage,
            Column.paymentRequest <- paymentRequest)
        )
    }
}
