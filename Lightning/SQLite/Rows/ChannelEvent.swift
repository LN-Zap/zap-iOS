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
struct ChannelEvent {
    enum ChanneEventType: Int {
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
    
    let txHash: String
    let node: ConnectedNode
    let blockHeight: Int
    
    let type: ChanneEventType
}

// SQL
extension ChannelEvent {
    private enum Column {
        static let txHash = Expression<String>("txHash")
        static let node = Expression<String>("pubKey")
        static let blockHeight = Expression<Int?>("blockHeight")
        static let type = Expression<Int>("type")
    }
    
    private static let table = Table("channelEvent")
    
    static func createTable(database: Connection) throws {
        try database.run(table.create(ifNotExists: true) { t in
            t.column(Column.txHash)
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
}
