//
//  Library
//
//  Created by 0 on 15.05.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Logger

/// Writes a backup method key + date to user defaults.
protocol BackupLogger: class {
    static var key: String { get }

    static func lastBackup(nodePubKey: String) -> Date?

    func didBackup(nodePubKey: String)
}

extension BackupLogger {
    static func lastBackup(nodePubKey: String) -> Date? {
        let result = UserDefaults.Keys.backupDates.get(defaultValue: [:])[nodePubKey]?[key]
        Logger.info("Last backup date for \(key): \(String(describing: result))", customPrefix: "📀")

        return result
    }

    static var key: String {
        return String(describing: self).components(separatedBy: ".").last ?? "unknown"
    }

    func didBackup(nodePubKey: String) {
        DispatchQueue.main.async {
            var backupDates = UserDefaults.Keys.backupDates.get(defaultValue: [:])

            if backupDates[nodePubKey] != nil {
                backupDates[nodePubKey]?[Self.key] = Date()
            } else {
                backupDates[nodePubKey] = [Self.key: Date()]
            }

            UserDefaults.Keys.backupDates.set(backupDates)
        }
    }
}
