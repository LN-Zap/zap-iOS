//
//  Lightning
//
//  Created by Otto Suess on 20.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SQLite

enum PersistenceError: Error {
    case noConnection
}

final class Persistence {
    private var currentConnection: Connection?
    private var pubKey: String?
    
    func connection() throws -> Connection {
        guard let connection = currentConnection else {
            throw PersistenceError.noConnection
        }
        return connection
    }
    
    func setConnectedNode(pubKey: String) {
        guard pubKey != self.pubKey else { return }
        self.pubKey = pubKey
        
        guard
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
            let connection = try? Connection("\(path)/\(pubKey).sqlite3")
            else { fatalError("can not open database") }
        
        connection.trace { print("💾", $0) }
        
        self.currentConnection = connection
        
        do {
            try createTables(in: connection)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func createTables(in database: Connection) throws {
        try ConnectedNode.createTable(database: database)
        try TransactionEvent.createTable(database: database)
        try FailedPaymentEvent.createTable(database: database)
        try CreateInvoiceEvent.createTable(database: database)
        try LightningPaymentEvent.createTable(database: database)
        try ChannelEvent.createTable(database: database)
    }
}
