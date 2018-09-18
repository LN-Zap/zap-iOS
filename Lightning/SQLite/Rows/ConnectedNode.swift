//
//  Lightning
//
//  Created by Otto Suess on 11.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SQLite

public struct ConnectedNode: Equatable {
    public let pubKey: String
    public let alias: String?
    public let color: String?
}

// SQL
extension ConnectedNode {
    enum Column {
        static let pubKey = Expression<String>("pubKey")
        static let alias = Expression<String?>("alias")
        static let color = Expression<String?>("color")
    }
    
    static let table = Table("connectedNodes")
    
    init(row: Row) {
        pubKey = row[Column.pubKey]
        alias = row[Column.alias]
        color = row[Column.color]
    }
    
    static func createTable(database: Connection) throws {
        try database.run(ConnectedNode.table.create(ifNotExists: true) { t in
            t.column(Column.pubKey, primaryKey: true)
            t.column(Column.alias)
            t.column(Column.color)
        })
    }
    
    func insert() throws {
        try SQLiteDataStore.shared.database.run(ConnectedNode.table.insert(
            or: .replace,
            Column.pubKey <- pubKey,
            Column.alias <- alias,
            Column.color <- color)
        )
    }
    
    func insertPubKey() throws {
        try SQLiteDataStore.shared.database.run(ConnectedNode.table.insert(or: .replace, Column.pubKey <- pubKey))
    }
}
