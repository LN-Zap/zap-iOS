//
//  Lightning
//
//  Created by Otto Suess on 20.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import Logger
import SQLite
import SwiftBTC
import SwiftLnd

enum PersistenceError: Error {
    case noConnection
}

protocol Persistence {
    func connection() throws -> Connection
    func setConnectedNode(connection: LightningConnection, pubKey: String)
}

private extension Connection {
    private static let tables: [ZapTable.Type] = [
        ConnectedNodeTable.self,
        TransactionTable.self,
        FailedPaymentTable.self,
        CreateInvoiceTable.self,
        LightningPaymentTable.self,
        ChannelEventTable.self,
        ReceivingAddressTable.self,
        MemoTable.self
    ]

    private static let currentUserVersion = 1

    func createTables() {
        if userVersion != Connection.currentUserVersion {
            do {
                try dropTables()
            } catch {
                Logger.error(error.localizedDescription)
            }
        }

        do {
            try Connection.tables.forEach {
                try $0.createTable(database: self)
                Logger.info("created db table '\($0)'")
            }
            userVersion = Connection.currentUserVersion
        } catch {
            Logger.info("Tables already exist.")
        }
    }

    func dropTables() throws {
        try Connection.tables.forEach {
            try run($0.table.drop(ifExists: true))
            Logger.info("dropped db table '\($0)'")
        }
    }

    var userVersion: Int {
        get {
            guard
                let scalar = try? scalar("PRAGMA user_version"),
                let int64 = scalar as? Int64
                else { return 0 }
            return Int(int64)
        }
        set {
            _ = try? run("PRAGMA user_version = \(Int32(newValue))")
        }
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
            connection.trace { Logger.verbose($0, customPrefix: "💾") }
        }

        self.currentConnection = connection

        connection.createTables()
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
            inMemoryConnection.createTables()
        } catch {
            fatalError("Could not setup in memory database.")
        }
    }

    func connection() throws -> Connection {
        return inMemoryConnection
    }

    func setConnectedNode(connection: LightningConnection, pubKey: String) {}
}
