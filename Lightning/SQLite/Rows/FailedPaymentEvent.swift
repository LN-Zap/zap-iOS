//
//  Lightning
//
//  Created by Otto Suess on 11.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation
import SQLite

/// Gets created when a payment request fails to complete.
struct FailedPaymentEvent {
    let paymentHash: String
    let memo: String?
    let amount: Satoshi?
    let destination: String
    let date: Date
    let expiry: Date
    let fallbackAddress: BitcoinAddress?
    let paymentRequest: String
}

// SQL
extension FailedPaymentEvent {
    private enum Column {
        static let paymentHash = Expression<String>("paymentHash")
        static let memo = Expression<String?>("memo")
        static let amount = Expression<Satoshi?>("amount")
        static let destination = Expression<String>("destination")
        static let date = Expression<Date>("date")
        static let expiry = Expression<Date>("expiry")
        static let fallbackAddress = Expression<String?>("fallbackAddress")
        static let paymentRequest = Expression<String>("paymentRequest")
    }
    
    private static let table = Table("failedPaymentEvent")

    static func createTable(connection: Connection) throws {
        try connection.run(table.create(ifNotExists: true) { t in
            t.column(Column.paymentHash, primaryKey: true)
            t.column(Column.memo)
            t.column(Column.amount)
            t.column(Column.destination)
            t.column(Column.date)
            t.column(Column.expiry)
            t.column(Column.fallbackAddress)
            t.column(Column.paymentRequest)
        })
    }
    
    func insert() throws {
        try SQLiteDataStore.shared.connection.run(FailedPaymentEvent.table.insert(
            Column.paymentHash <- paymentHash,
            Column.memo <- memo,
            Column.amount <- amount,
            Column.destination <- destination,
            Column.date <- date,
            Column.expiry <- expiry,
            Column.fallbackAddress <- fallbackAddress?.string,
            Column.paymentRequest <- paymentRequest)
        )
    }
}
