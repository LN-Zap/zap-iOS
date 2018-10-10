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
public struct TransactionEvent: Equatable, DateProvidingEvent, AmountProvidingEvent {
    public enum TransactionEventType: Int {
        case userInitiated = 0
        case channelRelated = 1
        case unknown = 2
    }

    public let txHash: String
    public let memo: String?
    public let amount: Satoshi
    public let fee: Satoshi
    public let date: Date
    public let destinationAddresses: [BitcoinAddress]
    public let blockHeight: Int? // nil if transaction is unconfirmed
    public let type: TransactionEventType
}

extension TransactionEvent {
    init?(transaction: Transaction) {
        guard transaction.amount != 0 else { return nil }
        
        txHash = transaction.id
        amount = transaction.amount
        fee = transaction.fees ?? 0
        memo = nil
        date = transaction.date
        destinationAddresses = transaction.destinationAddresses
        blockHeight = transaction.blockHeight
        type = .unknown
    }
}

// MARK: - Persistence
extension TransactionEvent {
    enum Column {
        static let txHash = Expression<String>("txHash")
        static let amount = Expression<Satoshi>("amount")
        static let fee = Expression<Satoshi>("fee")
        static let memo = Expression<String?>("memo")
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
        memo = row[Column.memo]
        date = row[Column.date]
        destinationAddresses = bitcoinAddresses
        blockHeight = row[Column.blockHeight]
        type = TransactionEventType(rawValue: row[Column.type]) ?? .unknown
    }
    
    static func createTable(database: Connection) throws {
        try database.run(table.create(ifNotExists: true) { t in
            t.column(Column.txHash, primaryKey: true)
            t.column(Column.amount)
            t.column(Column.fee)
            t.column(Column.memo)
            t.column(Column.date)
            t.column(Column.destinationAddresses)
            t.column(Column.blockHeight)
            t.column(Column.type, defaultValue: TransactionEventType.unknown.rawValue)
        })
    }
    
    func insert(database: Connection) throws {
        let addressString = destinationAddresses
            .map { $0.string }
            .joined(separator: ",")
        
        try database.run(TransactionEvent.table.insert(
            Column.txHash <- txHash,
            Column.amount <- amount,
            Column.fee <- fee,
            Column.memo <- memo,
            Column.date <- date,
            Column.destinationAddresses <- addressString,
            Column.blockHeight <- blockHeight,
            Column.type <- type.rawValue)
        )
    }
    
    static func events(query: Table = TransactionEvent.table, database: Connection) throws -> [TransactionEvent] {
        return try database.prepare(query)
            .map(TransactionEvent.init)
    }
    
    static func unconfirmedEvents(for txHashes: [String], database: Connection) throws -> [TransactionEvent] {
        let query = TransactionEvent.table
            .filter(Column.blockHeight == nil)
            .filter(txHashes.contains(Column.txHash))
        return try events(query: query, database: database)
    }
    
    public static func payments(database: Connection) throws -> [TransactionEvent] {
        let query = TransactionEvent.table
            .filter(Column.type != TransactionEventType.channelRelated.rawValue)
        return try events(query: query, database: database)
    }
    
    func updateBlockHeight(database: Connection) throws {
        let query = TransactionEvent.table
            .filter(Column.txHash == txHash)
            .filter(Column.blockHeight == nil)
            .limit(1)
        
        try database.run(query.update(Column.blockHeight <- blockHeight))
    }
}
