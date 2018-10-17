//
//  Lightning
//
//  Created by Otto Suess on 10.10.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SQLite
import SwiftBTC

// MARK: - Persistence
enum ReceivingAddress {
    private enum Column {
        static let address = Expression<String>("address")
    }
    
    private static let table = Table("receivingAddress")
    
    static func createTable(database: Connection) throws {
        try database.run(table.create(ifNotExists: true) { t in
            t.column(Column.address, primaryKey: true)
        })
    }
    
    static func insert(address: BitcoinAddress, database: Connection) throws {
        try database.run(ReceivingAddress.table.insert(
            Column.address <- address.string
        ))
    }
    
    public static func all(database: Connection) throws -> Set<BitcoinAddress> {
        var result = Set<BitcoinAddress>()
        for row in try database.prepare(table) {
            guard let address = BitcoinAddress(string: row[Column.address]) else { continue }
            result.insert(address)
        }
        return result
    }
}
