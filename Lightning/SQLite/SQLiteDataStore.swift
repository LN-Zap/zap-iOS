//
//  Lightning
//
//  Created by Otto Suess on 10.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SQLite

final class SQLiteDataStore {
    static let shared = SQLiteDataStore()
    let database: Connection
    
    private init() {
        let fileName = "db.sqlite3"
        
        guard
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
            let database = try? Connection("\(path)/\(fileName)")
            else { fatalError("can not open database") }
        
        database.trace { print($0) }

        self.database = database
    }
    
    func createTables() throws {
        try ConnectedNode.createTable(database: database)
        try TransactionEvent.createTable(database: database)
        try FailedPaymentEvent.createTable(database: database)
        try CreateInvoiceEvent.createTable(database: database)
        try LightningPaymentEvent.createTable(database: database)
        try ChannelEvent.createTable(database: database)
    }
}
