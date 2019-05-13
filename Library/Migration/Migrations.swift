//
//  Library
//
//  Created by 0 on 13.05.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Logger
import SwiftLnd

protocol Migration: class {
    func run()
}

extension Migration {
    fileprivate var didRun: Bool {
        set {
            guard let migrationKey = self.migrationKey else { return }
            var migrationKeys: [String] = UserDefaults.Keys.migrations.get(defaultValue: [])
            if newValue {
                if !migrationKeys.contains(migrationKey) {
                    migrationKeys.append(migrationKey)
                }
            } else {
                migrationKeys.removeAll { $0 == migrationKey }
            }

            UserDefaults.Keys.migrations.set(migrationKeys)
        }
        get {
            guard let migrationKey = self.migrationKey else { return false }
            let migrationKeys: [String] = UserDefaults.Keys.migrations.get(defaultValue: [])
            return migrationKeys.contains(migrationKey)
        }
    }

    fileprivate var migrationKey: String? {
        return String(describing: self).components(separatedBy: ".").last
    }
}

public enum Migrations {
    static let migrations: [Migration] = [
        RootFolderMigration()
    ]

    public static func run() {
        for migration in migrations where !migration.didRun {
            migration.run()
            Logger.info("did run migration: \(migration.migrationKey ?? "unknown")")
            migration.didRun = true
        }
    }
}
