//
//  Library
//
//  Created by 0 on 15.05.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

/// Writes a backup method key + date to user defaults.
protocol BackupLogger: class {
    static var lastBackup: Date? { get }
    static var key: String { get }

    func didBackup()
}

extension BackupLogger {
    static var lastBackup: Date? {
        return UserDefaults.Keys.backupDates.get(defaultValue: [:])[key]
    }

    static var key: String {
        return String(describing: self).components(separatedBy: ".").last ?? "unknown"
    }

    func didBackup() {
        var backupDates = UserDefaults.Keys.backupDates.get(defaultValue: [:])
        backupDates[Self.key] = Date()
        UserDefaults.Keys.backupDates.set(backupDates)
    }
}
