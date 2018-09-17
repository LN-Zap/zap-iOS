//
//  Lightning
//
//  Created by Otto Suess on 12.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation
import SQLite
import SwiftLnd

/// Does influence the balance of the user's wallet because a fee is payed.
public struct ChannelEvent: Equatable {
    public enum ChanneEventType: Int {
        case open
        case cooperativeClose
        case localForceClose
        case remoteForceClose
        case breachClose
        case fundingCanceled
        case unknown
        
        init(closeType: CloseType) {
            switch closeType {
            case .cooperativeClose:
                self = .cooperativeClose
            case .localForceClose:
                self = .localForceClose
            case .remoteForceClose:
                self = .remoteForceClose
            case .breachClose:
                self = .breachClose
            case .fundingCanceled:
                self = .fundingCanceled
            case .unknown:
                self = .unknown
            }
        }
    }
    
    public let txHash: String
    public let node: ConnectedNode
    public let blockHeight: Int
    public let type: ChanneEventType
    public let fee: Satoshi?
}

// SQL
extension ChannelEvent {
    private enum Column {
        static let txHash = Expression<String>("txHash")
        static let node = Expression<String>("node_pubKey")
        static let blockHeight = Expression<Int>("blockHeight")
        static let type = Expression<Int>("type")
    }
    
    private static let table = Table("channelEvent")
    
    init(row: Row) {
        txHash = row[ChannelEvent.table[Column.txHash]]
        blockHeight = row[ChannelEvent.table[Column.blockHeight]]
        type = ChannelEvent.ChanneEventType(rawValue: row[Column.type]) ?? .unknown
        node = ConnectedNode(row: row)
    
        fee = 0
//        fee = row[TransactionEvent.Column.fee]
    }
    
    static func createTable(database: Connection) throws {
        try database.run(table.create(ifNotExists: true) { t in
            t.column(Column.txHash, primaryKey: true)
            t.column(Column.node)
            t.column(Column.blockHeight)
            t.column(Column.type)
            t.foreignKey(Column.txHash, references: TransactionEvent.table, TransactionEvent.Column.txHash)
            t.foreignKey(Column.node, references: ConnectedNode.table, ConnectedNode.Column.pubKey)
        })
    }
    
    func insert() throws {
        try SQLiteDataStore.shared.database.run(ChannelEvent.table.insert(
            Column.txHash <- txHash,
            Column.node <- node.pubKey,
            Column.blockHeight <- blockHeight,
            Column.type <- type.rawValue)
        )
        
        try node.insertPubKey()
    }
    
    public static func events() throws -> [ChannelEvent] {
        let query = ChannelEvent.table
            .join(ConnectedNode.table, on: ConnectedNode.Column.pubKey == ChannelEvent.table[Column.node])
            .join(.leftOuter, TransactionEvent.table, on: TransactionEvent.table[TransactionEvent.Column.txHash] == ChannelEvent.table[Column.txHash])
            .order(Column.blockHeight.desc)
        return try SQLiteDataStore.shared.database.prepare(query)
            .map(ChannelEvent.init)
    }
}
