//
//  Lightning
//
//  Created by 0 on 05.03.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import SQLite
import SwiftBTC

struct ReceivingAddressTable: Hashable {
    let address: BitcoinAddress
}

extension ReceivingAddressTable: ZapTable {
    private enum Column {
        static let address = Expression<String>("address")
    }

    static let table = Table("receivingAddress")

    init?(row: Row) {
        guard let address = BitcoinAddress(string: row[Column.address]) else { return nil }
        self.address = address
    }

    static func createTable(database: Connection) throws {
        try database.run(table.create { t in
            t.column(Column.address, primaryKey: true)
        })
    }

    func insert(database: Connection) throws {
        try database.run(ReceivingAddressTable.table.insert(
            Column.address <- address.string
        ))
    }

    public static func all(database: Connection) throws -> Set<ReceivingAddressTable> {
        let array = try database.prepare(table)
            .compactMap(ReceivingAddressTable.init)
        return Set(array)
    }
}
