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
    let connection: Connection
    
    private init() {
        let fileName = "db.sqlite3"
        
        guard
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
            let connection = try? Connection("\(path)/\(fileName)")
            else { fatalError("can not open database") }
        
        connection.trace { print($0) }

        self.connection = connection
    }
    
    func createTables() throws {
        try ConnectedNodes.createTable(connection: connection)
        try OnChainPaymentEvent.createTable(connection: connection)
        try FailedPaymentEvent.createTable(connection: connection)
        try CreateInvoiceEvent.createTable(connection: connection)
        try LightningPaymentEvent.createTable(connection: connection)
        try ChannelEvent.createTable(connection: connection)
    }
}
