//
//  Lightning
//
//  Created by Otto Suess on 12.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation
import SQLite

/// Does influence the balance of the user's wallet because a fee is payed.
struct ChannelEvent {
    enum ChanneEventType: Int {
        case open
        case cooperativeClose
        case localForceClose
        case remoteForceClose
        case breachClose
        case fundingCanceled
    }
    
    let transaction: Transaction
    let node: ConnectedNodes

    let type: ChanneEventType
    let fee: Satoshi
}

// SQL
extension ChannelEvent {
    private enum Column {
        static let transaction = Expression<String>("transaction_id")
        static let node = Expression<String>("node_id")
        static let fee = Expression<Satoshi>("fee")
        static let type = Expression<Int>("type")
    }
    
    private static let table = Table("channelEvent")
    
    static func createTable(connection: Connection) throws {
        try connection.run(table.create(ifNotExists: true) { t in
            t.column(Column.transaction)
            t.column(Column.node)
            t.column(Column.fee)
            t.column(Column.type)
            t.foreignKey(Column.transaction, references: OnChainPaymentEvent.table, OnChainPaymentEvent.Column.txHash)
            t.foreignKey(Column.node, references: ConnectedNodes.table, ConnectedNodes.Column.pubKey)
        })
    }
}
