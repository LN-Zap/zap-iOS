//
//  Lightning
//
//  Created by 0 on 05.03.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import SQLite
import SwiftBTC

struct TransactionTable {
    let txHash: String
    let amount: Satoshi
    let fee: Satoshi?
    let date: Date
    let destinationAddresses: [BitcoinAddress]
    let blockHeight: Int? // nil if transaction is unconfirmed
    let type: TransactionEvent.TransactionEventType
}

extension TransactionTable: ZapTable {
    enum Column {
        static let txHash = Expression<String>("txHash")
        static let amount = Expression<Satoshi>("amount")
        static let fee = Expression<Satoshi?>("fee")
        static let date = Expression<Date>("date")
        static let destinationAddresses = Expression<String>("destinationAddresses")
        static let blockHeight = Expression<Int?>("blockHeight")
        static let type = Expression<Int>("transactionType")
    }

    static let table = Table("transactionEvent")

    init(row: Row) {
        let bitcoinAddresses = row[Column.destinationAddresses]
            .split(separator: ",")
            .compactMap { BitcoinAddress(string: String($0)) }

        txHash = row[Column.txHash]
        amount = row[Column.amount]
        fee = row[Column.fee]
        date = row[Column.date]
        destinationAddresses = bitcoinAddresses
        blockHeight = row[Column.blockHeight]
        type = TransactionEvent.TransactionEventType(rawValue: row[Column.type]) ?? .unknown
    }

    static func createTable(database: Connection) throws {
        try database.run(table.create(ifNotExists: true) { t in
            t.column(Column.txHash, primaryKey: true)
            t.column(Column.amount)
            t.column(Column.fee)
            t.column(Column.date)
            t.column(Column.destinationAddresses)
            t.column(Column.blockHeight)
            t.column(Column.type, defaultValue: TransactionEvent.TransactionEventType.unknown.rawValue)
        })
    }

    func insert(database: Connection) throws {
        try database.run(TransactionTable.table.insert(
            Column.txHash <- txHash,
            Column.amount <- amount,
            Column.fee <- fee,
            Column.date <- date,
            Column.destinationAddresses <- addressString,
            Column.blockHeight <- blockHeight,
            Column.type <- type.rawValue
        ))
    }

    private var addressString: String {
        return destinationAddresses
            .map { $0.string }
            .joined(separator: ",")
    }
}
