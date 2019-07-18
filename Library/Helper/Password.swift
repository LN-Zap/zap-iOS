//
//  Lightning
//
//  Created by 0 on 16.07.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import KeychainAccess

enum Password {
    private static let keychain = Keychain(serviceExtension: "wallet_password").accessibility(.whenUnlocked)
    private static let key = "password"

    static func create() -> String {
        // if not available create new one.
        if let password = try? Password.keychain.get(Password.key) {
            return password
        }

        let length = 48
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789,.?<>-_!@#$%^&*()"
        let password = String((0..<length).compactMap { _ in characters.randomElement() })

        // save
        do {
            try Password.keychain.set(password, key: Password.key)
        } catch {
            fatalError("could not access keychain")
        }

        return password
    }

    static func get() -> String {
        return (try? Password.keychain.get(Password.key)) ?? "12345678"
    }
}
