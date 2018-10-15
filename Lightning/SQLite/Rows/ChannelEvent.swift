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
        case abandoned
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
            case .abandoned:
                self = .abandoned
            }
        }
    }
    
    public let txHash: String
    public let node: ConnectedNode
    public let blockHeight: Int
    public let type: ChanneEventType
    public let fee: Satoshi?
}

extension ChannelEvent {
    init?(channel: Channel) {
        guard let blockHeight = channel.blockHeight else { return nil }
        txHash = channel.channelPoint.fundingTxid
        node = ConnectedNode(pubKey: channel.remotePubKey, alias: nil, color: nil)
        self.blockHeight = blockHeight
        type = .open
        fee = nil
    }
    
    init(closing channelCloseSummary: ChannelCloseSummary) {
        txHash = channelCloseSummary.closingTxHash
        node = ConnectedNode(pubKey: channelCloseSummary.remotePubKey, alias: nil, color: nil)
        blockHeight = channelCloseSummary.closeHeight
        type = ChannelEvent.ChanneEventType(closeType: channelCloseSummary.closeType)
        fee = nil
    }
    
    init(opening channelCloseSummary: ChannelCloseSummary) {
        txHash = channelCloseSummary.channelPoint.fundingTxid
        node = ConnectedNode(pubKey: channelCloseSummary.remotePubKey, alias: nil, color: nil)
        blockHeight = channelCloseSummary.openHeight
        type = .open
        fee = nil
    }

}

// MARK: - Persistence
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
        fee = (try? row.get(TransactionEvent.Column.fee)) ?? nil // swiftlint:disable:this redundant_nil_coalescing
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
    
    func insert(database: Connection) throws {
        try database.run(ChannelEvent.table.insert(
            Column.txHash <- txHash,
            Column.node <- node.pubKey,
            Column.blockHeight <- blockHeight,
            Column.type <- type.rawValue)
        )
        
        try node.insertPubKey(database: database)
    }
    
    public static func events(database: Connection) throws -> [ChannelEvent] {
        let query = table
            .join(ConnectedNode.table, on: ConnectedNode.Column.pubKey == table[Column.node])
            .join(.leftOuter, TransactionEvent.table, on: TransactionEvent.table[TransactionEvent.Column.txHash] == ChannelEvent.table[Column.txHash])
            .order(Column.blockHeight.desc)
        return try database.prepare(query)
            .map(ChannelEvent.init)
    }
}
