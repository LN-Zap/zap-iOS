//
//  Library
//
//  Created by 0 on 18.06.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

struct StaticChannelBackupResult: Codable {
    let errors: [StaticChannelBackupError]
    let successfulServiceKeys: [String]
    let timestamp: Date?
}

enum StaticChannelBackupStateStore {
    private static func result(for nodePubKey: String) -> StaticChannelBackupResult? {
        guard let data = UserDefaults.Keys.backupDates.get(defaultValue: [:])[nodePubKey] else { return nil }
        return try? JSONDecoder().decode(StaticChannelBackupResult.self, from: data)
    }

    static func didBackup(nodePubKey: String, backupServiceKey: String) -> Bool {
        return result(for: nodePubKey)?.successfulServiceKeys.contains(backupServiceKey) ?? false
    }

    static func lastBackup(nodePubKey: String, backupServiceKeys: [String]) -> Date? {
        return result(for: nodePubKey)?.timestamp
    }

    static func errorMessages(nodePubKey: String, backupServiceKeys: [String]) -> [StaticChannelBackupError] {
        return result(for: nodePubKey)?.errors ?? []

    }

    static func update(nodePubKey: String, data: StaticChannelBackupResult) {
        guard let data = try? JSONEncoder().encode(data) else { return }

        var dates = UserDefaults.Keys.backupDates.get(defaultValue: [:])
        dates[nodePubKey] = data
        UserDefaults.Keys.backupDates.set(dates)
    }
}
