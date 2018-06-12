//
//  Zap
//
//  Created by Otto Suess on 19.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

extension UserDefaults {
    enum Keys {
        static let mnemonic = DefaultKey<[String]>("mnemonic")
        static let didCreateWallet = DefaultKey<Bool>("didCreateWallet")
    }
}

final class DefaultKey<T> {
    private let name: String
    
    init(_ name: String) {
        self.name = name
    }

    func get<T>() -> T? {
        return UserDefaults.standard.value(forKey: name) as? T
    }
    
    func get<T>(defaultValue: T) -> T {
        return (UserDefaults.standard.value(forKey: name) as? T) ?? defaultValue
    }
    
    func set<T>(_ value: T?) {
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
