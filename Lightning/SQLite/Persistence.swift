//
//  Lightning
//
//  Created by Otto Suess on 20.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SQLite
import SwiftLnd

enum PersistenceError: Error {
    case noConnection
}

protocol Persistence {
    func connection() throws -> Connection
    func setConnectedNode(connection: LightningConnection, pubKey: String)
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
    
    init(walletId: WalletId) {
        guard
            let url = FileManager.default.walletDirectory(for: walletId)?.appendingPathComponent("data.sqlite3"),
            let connection = try? Connection(url.path)
            else { fatalError("can not connect to db.") }
    
        if Environment.traceDB {
            connection.trace { print("💾", $0) }
        }
        
        self.currentConnection = connection
        
        do {
            try connection.createTables()
        } catch {
            print("🤮 \(error.localizedDescription)")
        }
    }
    
    func connection() throws -> Connection {
        guard let connection = currentConnection else {
            throw PersistenceError.noConnection
        }
        return connection
    }
    
    func setConnectedNode(connection: LightningConnection, pubKey: String) {
        
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
    
    func setConnectedNode(connection: LightningConnection, pubKey: String) {}
}
