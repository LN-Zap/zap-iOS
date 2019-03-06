//
//  Lightning
//
//  Created by 0 on 06.03.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import SQLite
import SwiftBTC

struct LightningPaymentTable {
    public let paymentHash: String
    public let amount: Satoshi
    public let fee: Satoshi
    public let date: Date
    public let destination: String?
}

extension LightningPaymentTable: ZapTable {
    enum Column {
        static let paymentHash = Expression<String>("paymentHash")
        static let amount = Expression<Satoshi>("amount")
        static let fee = Expression<Satoshi>("fee")
        static let date = Expression<Date>("date")
        static let destination = Expression<String?>("destination")
    }

    static let table = Table("lightningPaymentEvent")

    init(row: Row) {
        paymentHash = row[Column.paymentHash]
        amount = row[Column.amount]
        fee = row[Column.fee]
        date = row[Column.date]
        destination = row[Column.destination]
    }

    static func createTable(database: Connection) throws {
        try database.run(table.create(ifNotExists: true) { t in
            t.column(Column.paymentHash, primaryKey: true)
            t.column(Column.amount)
            t.column(Column.fee)
            t.column(Column.date)
            t.column(Column.destination)
        })
    }

    func insert(database: Connection) throws {
        try database.run(LightningPaymentTable.table.insert(
            Column.paymentHash <- paymentHash,
            Column.amount <- amount,
            Column.fee <- fee,
            Column.date <- date,
            Column.destination <- destination)
        )
    }
}
