//
//  Lightning
//
//  Created by Otto Suess on 11.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SQLite
import SwiftBTC
import SwiftLnd

/*
 This is any event that transfers bitcoin from one wallet to another.
 Includes transactions, except those resulting from opening or closing channels.
 */
public struct TransactionEvent: Equatable, DateProvidingEvent, AmountProvidingEvent {
    public enum Kind: Int {
        case userInitiated = 0
        case channelRelated = 1
        case unknown = 2
    }

    public let txHash: String
    public let memo: String?
    public let amount: Satoshi
    public let fee: Satoshi?
    public let date: Date
    public let destinationAddresses: [BitcoinAddress]
    public let blockHeight: Int? // nil if transaction is unconfirmed
    public let type: Kind
}

extension TransactionEvent {
    init?(transaction: Transaction, type: Kind = .unknown) {
        guard transaction.amount != 0 else { return nil }

        txHash = transaction.id
        amount = transaction.amount
        fee = transaction.fees ?? 0
        memo = nil
        date = transaction.date
        destinationAddresses = transaction.destinationAddresses
        blockHeight = transaction.blockHeight
        self.type = type
    }

    init(txHash: String, bitcoinURI: BitcoinURI, amount: Satoshi) {
        self.txHash = txHash
        memo = bitcoinURI.memo
        self.amount = amount
        fee = nil
        date = Date()
        destinationAddresses = [bitcoinURI.bitcoinAddress]
        blockHeight = nil
        type = .userInitiated
    }
}

// MARK: - Persistence
extension TransactionEvent {
    private var transactionTable: TransactionTable {
        return TransactionTable(txHash: txHash,
                                amount: amount,
                                fee: fee,
                                date: date,
                                destinationAddresses: destinationAddresses,
                                blockHeight: blockHeight,
                                type: type)
    }

    init(row: Row) {
        let transaction = TransactionTable(row: row)
        txHash = transaction.txHash
        memo = MemoTable(row: row)?.text
        amount = transaction.amount
        fee = transaction.fee
        date = transaction.date
        destinationAddresses = transaction.destinationAddresses
        blockHeight = transaction.blockHeight
        type = transaction.type
    }

    static func events(query: Table = TransactionTable.table, database: Connection) throws -> [TransactionEvent] {
        return try database.prepare(query
            .join(.leftOuter, MemoTable.table, on: MemoTable.Column.id == TransactionTable.table[TransactionTable.Column.txHash]))
            .map(TransactionEvent.init)
    }

    static func unconfirmedEvents(for txHashes: [String], database: Connection) throws -> [TransactionEvent] {
        let query = TransactionTable.table
            .filter(TransactionTable.Column.blockHeight == nil)
            .filter(txHashes.contains(TransactionTable.Column.txHash))
        return try events(query: query, database: database)
    }

    public static func payments(database: Connection) throws -> [TransactionEvent] {
        let query = TransactionTable.table
            .filter(TransactionTable.Column.type != Kind.channelRelated.rawValue)
        return try events(query: query, database: database)
    }

    func insertOrUpdateTransactionData(database: Connection) throws {
        do {
            try insert(database: database)
        } catch {
            try transactionTable.updateTransactionData(database: database)
        }
    }

    func insertOrUpdateMetaData(database: Connection) throws {
        try insertOrUpdateType(database: database)
        try MemoTable(id: txHash, text: memo)?.insert(database: database)
    }

    private func insertOrUpdateType(database: Connection) throws {
        do {
            try insert(database: database)
        } catch {
            try transactionTable.updateType(database: database)
        }
    }

    private func insert(database: Connection) throws {
        try transactionTable.insert(database: database)
        try MemoTable(id: txHash, text: memo)?.insert(database: database)
    }
}
