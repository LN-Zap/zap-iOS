//
//  Lightning
//
//  Created by Otto Suess on 11.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SQLite
import SwiftLnd

public struct ConnectedNodeTable: Equatable {
    public let pubKey: String
    public let alias: String?
    public let color: String?
}

extension ConnectedNodeTable {
    init(lightningNode: LightningNode) {
        self.pubKey = lightningNode.pubKey
        self.alias = lightningNode.alias
        self.color = lightningNode.color
    }
}

// MARK: - Persistence
extension ConnectedNodeTable: ZapTable {
    enum Column {
        static let pubKey = Expression<String>("pubKey")
        static let alias = Expression<String?>("alias")
        static let color = Expression<String?>("color")
    }

    static let table = Table("connectedNodes")

    init?(row: Row) {
        guard let pubKey = try? row.get(Column.pubKey) else { return nil }

        self.pubKey = pubKey

        if let alias = try? row.get(Column.alias) {
            self.alias = alias
        } else {
            alias = nil
        }

        if let color = try? row.get(Column.color) {
            self.color = color
        } else {
            color = nil
        }
    }

    static func createTable(database: Connection) throws {
        try database.run(ConnectedNodeTable.table.create { t in
            t.column(Column.pubKey, primaryKey: true)
            t.column(Column.alias)
            t.column(Column.color)
        })
    }

    func insert(database: Connection) throws {
        try database.run(ConnectedNodeTable.table.insert(
            or: .replace,
            Column.pubKey <- pubKey,
            Column.alias <- alias,
            Column.color <- color)
        )
    }

    func insertPubKey(database: Connection) throws {
        try database.run(ConnectedNodeTable.table.insert(or: .replace, Column.pubKey <- pubKey))
    }
}
