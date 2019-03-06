//
//  Lightning
//
//  Created by 0 on 06.03.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import SQLite
import SwiftBTC

struct ChannelEventTable {
    let txHash: String
    let nodePubKey: String
    let blockHeight: Int
    let type: ChannelEvent.Kind
}

extension ChannelEventTable: ZapTable {
    enum Column {
        static let txHash = Expression<String>("txHash")
        static let nodePubKey = Expression<String>("node_pubKey")
        static let blockHeight = Expression<Int>("blockHeight")
        static let type = Expression<Int>("type")
    }

    static let table = Table("channelEvent")

    init(row: Row) {
        txHash = row[ChannelEventTable.table[Column.txHash]]
        blockHeight = row[ChannelEventTable.table[Column.blockHeight]]
        type = ChannelEvent.Kind(rawValue: row[Column.type]) ?? .unknown
        nodePubKey = row[ChannelEventTable.table[Column.nodePubKey]]
    }

    static func createTable(database: Connection) throws {
        try database.run(table.create(ifNotExists: true) { t in
            t.column(Column.txHash, primaryKey: true)
            t.column(Column.nodePubKey)
            t.column(Column.blockHeight)
            t.column(Column.type)
            t.foreignKey(Column.txHash, references: TransactionTable.table, TransactionTable.Column.txHash)
            t.foreignKey(Column.nodePubKey, references: ConnectedNodeTable.table, ConnectedNodeTable.Column.pubKey)
        })
    }

    func insert(database: Connection) throws {
        try database.run(ChannelEventTable.table.insert(
            Column.txHash <- txHash,
            Column.nodePubKey <- nodePubKey,
            Column.blockHeight <- blockHeight,
            Column.type <- type.rawValue)
        )
    }
}
