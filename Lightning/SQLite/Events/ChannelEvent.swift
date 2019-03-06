//
//  Lightning
//
//  Created by Otto Suess on 12.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SQLite
import SwiftBTC
import SwiftLnd

/// Does influence the balance of the user's wallet because a fee is payed.
public struct ChannelEvent: Equatable {
    public enum ChanneEventType: Int { // TODO: rename
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
    public let node: LightningNode
    public let blockHeight: Int
    public let type: ChanneEventType
    public let fee: Satoshi?
}

extension ChannelEvent {
    init?(channel: Channel) {
        guard let blockHeight = channel.blockHeight else { return nil }
        txHash = channel.channelPoint.fundingTxid
        node = LightningNode(pubKey: channel.remotePubKey, alias: nil, color: nil)
        self.blockHeight = blockHeight
        type = .open
        fee = nil
    }

    init(closing channelCloseSummary: ChannelCloseSummary) {
        txHash = channelCloseSummary.closingTxHash
        node = LightningNode(pubKey: channelCloseSummary.remotePubKey, alias: nil, color: nil)
        blockHeight = channelCloseSummary.closeHeight
        type = ChannelEvent.ChanneEventType(closeType: channelCloseSummary.closeType)
        fee = nil
    }

    init(opening channelCloseSummary: ChannelCloseSummary) {
        txHash = channelCloseSummary.channelPoint.fundingTxid
        node = LightningNode(pubKey: channelCloseSummary.remotePubKey, alias: nil, color: nil)
        blockHeight = channelCloseSummary.openHeight
        type = .open
        fee = nil
    }
}

// MARK: - Persistence
extension ChannelEvent {
    init(row: Row) {
        let channelEventTable = ChannelEventTable(row: row)
        txHash = channelEventTable.txHash
        blockHeight = channelEventTable.blockHeight
        type = channelEventTable.type

        if let nodeTable = ConnectedNodeTable(row: row) {
            node = LightningNode(pubKey: nodeTable.pubKey, alias: nodeTable.alias, color: nodeTable.color)
        } else {
            node = LightningNode(pubKey: channelEventTable.nodePubKey, alias: nil, color: nil)
        }

        fee = (try? row.get(TransactionTable.Column.fee)) ?? nil // swiftlint:disable:this redundant_nil_coalescing
    }

    public static func events(database: Connection) throws -> [ChannelEvent] {
        let query = ChannelEventTable.table
            .join(ConnectedNodeTable.table, on: ConnectedNodeTable.Column.pubKey == ChannelEventTable.table[ChannelEventTable.Column.nodePubKey])
            .join(.leftOuter, TransactionTable.table, on: TransactionTable.table[TransactionTable.Column.txHash] == ChannelEventTable.table[ChannelEventTable.Column.txHash])
            .order(ChannelEventTable.Column.blockHeight.desc)
        return try database.prepare(query)
            .map(ChannelEvent.init)
    }

    func insert(database: Connection) throws {
        try ChannelEventTable(txHash: txHash, nodePubKey: node.pubKey, blockHeight: blockHeight, type: type).insert(database: database)
        try ConnectedNodeTable(lightningNode: node).insertPubKey(database: database)
    }
}
