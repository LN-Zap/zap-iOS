//
//  Lightning
//
//  Created by Otto Suess on 22.02.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import SQLite

struct MemoTable {
    public let id: String
    public let text: String

    init?(id: String, text: String?) {
        guard
            let text = text?.trimmingCharacters(in: .whitespacesAndNewlines),
            !text.isEmpty
            else { return nil }

        self.id = id
        self.text = text
    }
}

extension MemoTable: ZapTable {
    enum Column {
        static let id = Expression<String>("memoId")
        static let text = Expression<String>("memo")
    }

    static let table = Table("memo")

    init?(row: Row) {
        guard
            let id = try? row.get(Column.id),
            let text = try? row.get(Column.text)
            else { return nil }

        self.id = id
        self.text = text
    }

    static func createTable(database: Connection) throws {
        try database.run(table.create { t in
            t.column(Column.id, primaryKey: true)
            t.column(Column.text)
        })
    }

    func insert(database: Connection) throws {
        try database.run(MemoTable.table.insert(
            or: .ignore,
            Column.id <- id,
            Column.text <- text
        ))
    }
}
