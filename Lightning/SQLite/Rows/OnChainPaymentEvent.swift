//
//  Lightning
//
//  Created by Otto Suess on 11.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation
import SQLite
import SwiftLnd

/*
 This is any event that transfers bitcoin from one wallet to another.
 Includes transactions, except those resulting from opening or closing channels.
 */
struct OnChainPaymentEvent {
    let txHash: String
    let memo: String?
    let amount: Satoshi
    let fee: Satoshi
    let date: Date
    let destinationAddresses: [BitcoinAddress]
    let blockHeight: Int? // nil if transaction is unconfirmed
}

extension OnChainPaymentEvent {
    init(transaction: OnChainConfirmedTransaction) {
        txHash = transaction.id
        amount = transaction.amount
        fee = transaction.fees ?? 0
        memo = nil
        date = transaction.date
        destinationAddresses = transaction.destinationAddresses
        blockHeight = transaction.blockHeight
    }
}

// SQL
extension OnChainPaymentEvent {
    enum Column {
        static let txHash = Expression<String>("txHash")
        static let amount = Expression<Satoshi>("amount")
        static let fee = Expression<Satoshi>("fee")
        static let memo = Expression<String?>("memo")
        static let date = Expression<Date>("date")
        static let destinationAddresses = Expression<String>("destinationAddresses")
        static let blockHeight = Expression<Int?>("blockHeight")
    }
    
    static let table = Table("onChainPaymentEvent")
    
    init(row: Row) {
        let bitcoinAddresses = row[Column.destinationAddresses]
            .split(separator: ",")
            .compactMap { BitcoinAddress(string: String($0)) }
        
        txHash = row[Column.txHash]
        amount = row[Column.amount]
        fee = row[Column.fee]
        memo = row[Column.memo]
        date = row[Column.date]
        destinationAddresses = bitcoinAddresses
        blockHeight = row[Column.blockHeight]
    }
    
    static func createTable(connection: Connection) throws {
        try connection.run(table.create(ifNotExists: true) { t in
            t.column(Column.txHash, primaryKey: true)
            t.column(Column.amount)
            t.column(Column.fee)
            t.column(Column.memo)
            t.column(Column.date)
            t.column(Column.destinationAddresses)
            t.column(Column.blockHeight)
        })
    }
    
    func insert() throws {
        let addressString = destinationAddresses
            .map { $0.string }
            .joined(separator: ",")
        
        try SQLiteDataStore.shared.connection.run(OnChainPaymentEvent.table.insert(
            Column.txHash <- txHash,
            Column.amount <- amount,
            Column.fee <- fee,
            Column.memo <- memo,
            Column.date <- date,
            Column.destinationAddresses <- addressString,
            Column.blockHeight <- blockHeight)
        )
    }
    
    static func events(query: Table = OnChainPaymentEvent.table) throws -> [OnChainPaymentEvent] {
        return try SQLiteDataStore.shared.connection.prepare(query)
            .map(OnChainPaymentEvent.init)
    }
    
    static func unconfirmedEvents(for txHashes: [String]) throws -> [OnChainPaymentEvent] {
        let query = OnChainPaymentEvent.table
            .filter(Column.blockHeight == nil)
            .filter(txHashes.contains(Column.txHash))
        return try events(query: query)
    }
    
    func updateBlockHeight() throws -> Bool {
        let query = OnChainPaymentEvent.table
            .filter(Column.txHash == txHash)
            .filter(Column.blockHeight == nil)
            .limit(1)
        
        return try SQLiteDataStore.shared.connection.run(query.update(Column.blockHeight <- blockHeight)) > 0
    }
}
