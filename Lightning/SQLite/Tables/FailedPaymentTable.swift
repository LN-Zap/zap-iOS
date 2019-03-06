//
//  Lightning
//
//  Created by 0 on 06.03.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import SQLite
import SwiftBTC

struct FailedPaymentTable {
    let paymentHash: String
    let amount: Satoshi
    let destination: String
    let date: Date
    let expiry: Date
    let fallbackAddress: BitcoinAddress?
    let paymentRequest: String
}

extension FailedPaymentTable: ZapTable {
    enum Column {
        static let paymentHash = Expression<String>("paymentHash")
        static let amount = Expression<Satoshi>("amount")
        static let destination = Expression<String>("destination")
        static let date = Expression<Date>("date")
        static let expiry = Expression<Date>("expiry")
        static let fallbackAddress = Expression<String?>("fallbackAddress")
        static let paymentRequest = Expression<String>("paymentRequest")
    }

    static let table = Table("failedPaymentEvent")

    init(row: Row) {
        paymentHash = row[Column.paymentHash]
        amount = row[Column.amount]
        date = row[Column.date]
        expiry = row[Column.expiry]
        paymentRequest = row[Column.paymentRequest]
        destination = row[Column.destination]

        if let addressString = row[Column.fallbackAddress] {
            fallbackAddress = BitcoinAddress(string: addressString)
        } else {
            fallbackAddress = nil
        }
    }

    static func createTable(database: Connection) throws {
        try database.run(table.create(ifNotExists: true) { t in
            t.column(Column.paymentHash, primaryKey: true)
            t.column(Column.amount)
            t.column(Column.destination)
            t.column(Column.date)
            t.column(Column.expiry)
            t.column(Column.fallbackAddress)
            t.column(Column.paymentRequest)
        })
    }

    func insert(database: Connection) throws {
        try database.run(FailedPaymentTable.table.insert(
            Column.paymentHash <- paymentHash,
            Column.amount <- amount,
            Column.destination <- destination,
            Column.date <- date,
            Column.expiry <- expiry,
            Column.fallbackAddress <- fallbackAddress?.string,
            Column.paymentRequest <- paymentRequest)
        )
    }
}
