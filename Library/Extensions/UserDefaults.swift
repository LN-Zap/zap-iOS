//
//  Zap
//
//  Created by Otto Suess on 19.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

extension UserDefaults {
    enum Keys {
        static let didCreateWallet = DefaultKey<Bool>("didCreateWallet")
        static let didSelectContinueToBlockExplorer = DefaultKey<Bool>("didSelectContinueToBlockExplorer")
        static let lastSeenHistoryDate = DefaultKey<Date>("lastSeenHistoryDate")
        static let walletDetailExpanded = DefaultKey<Bool>("homeScreenTileExpanded")
        static let migrations = DefaultKey<[String]>("migrations")
        static let backupDates = DefaultKey<[String: Data]>("backupDates")
    }
}

final class DefaultKey<T> {
    private let name: String

    init(_ name: String) {
        self.name = name
    }

    func get() -> T? {
        return UserDefaults.standard.value(forKey: name) as? T
    }

    func get(defaultValue: T) -> T {
        return (UserDefaults.standard.value(forKey: name) as? T) ?? defaultValue
    }

    func set(_ value: T?) {
        if let value = value {
            UserDefaults.standard.setValue(value, forKey: name)
            UserDefaults.standard.synchronize()
        } else {
            removeValue()
        }
    }

    func removeValue() {
        UserDefaults.standard.removeObject(forKey: name)
        UserDefaults.standard.synchronize()
    }
}
