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

protocol Persistence {
    func connection() throws -> Connection
    func setConnectedNode(pubKey: String)
}

fileprivate extension Connection {
    func createTables() throws {
        try ConnectedNode.createTable(database: self)
        try TransactionEvent.createTable(database: self)
        try FailedPaymentEvent.createTable(database: self)
        try CreateInvoiceEvent.createTable(database: self)
        try LightningPaymentEvent.createTable(database: self)
        try ChannelEvent.createTable(database: self)
        try ReceivingAddress.createTable(database: self)
    }
}

final class SQLitePersistence: Persistence {
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
            try connection.createTables()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

class MockPersistence: Persistence {
    let inMemoryConnection: Connection
    
    init() {
        do {
            inMemoryConnection = try Connection(.inMemory)
            try inMemoryConnection.createTables()
        } catch {
            fatalError("Could not setup in memory database.")
        }
    }
    
    func connection() throws -> Connection {
        return inMemoryConnection
    }
    
    func setConnectedNode(pubKey: String) {}
}
