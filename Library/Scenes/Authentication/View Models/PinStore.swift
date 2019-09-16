//
//  Library
//
//  Created by 0 on 26.02.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import KeychainAccess

enum PinStore {
    private enum Key {
        static let pin = "PBKDF2Pin"
        static let pinCount = "PBKDF2PinCount"
        static let pbkdf2Rounds = "PBKDF2Rounds"
    }

    private static let salt = "kZF86kneOPAm09Wpl6XOLixuyctCM/lK"

    private static let keychain = Keychain(serviceExtension: "password").accessibility(.whenUnlocked)
    private static let didSetupPinKey = DefaultKey<Bool>("didSetupPin")

    private(set) static var didSetupPin: Bool {
        get {
            guard !Environment.skipPinFlow else { return true }
            return didSetupPinKey.get() ?? false
        }
        set {
            didSetupPinKey.set(newValue)
        }
    }

    static func update(pin: String) {
        let rounds = PBKDF2.rounds(passwordCount: pin.count, saltCount: salt.count, seconds: 0.2)
        PinStore.rounds = rounds
        PinStore.hashedPin = hashPin(pin, rounds: rounds)
        PinStore.pinCount = pin.count
        didSetupPin = true
    }

    static func isCorrect(pin: String) -> Bool {
        guard
            let rounds = PinStore.rounds,
            let hashedPin = PinStore.hashedPin
            else { return false }

        return PinStore.hashPin(pin, rounds: rounds) == hashedPin
    }

    static var pinCount: Int? {
        get {
            guard let string = keychain[Key.pinCount] else { return nil }
            return Int(string)
        }
        set {
            if let newValue = newValue {
                keychain[Key.pinCount] = String(newValue)
            } else {
                keychain[Key.pinCount] = nil
            }
        }
    }

    // MARK: private

    private static func hashPin(_ pin: String, rounds: Int) -> Data {
        guard let result = PBKDF2.keyFor(password: pin, salt: salt, rounds: rounds) else { fatalError("PBKDF2 failed") }
        return result
    }

    private static var hashedPin: Data? {
        get { return keychain[data: Key.pin] }
        set { keychain[data: Key.pin] = newValue }
    }

    private static var rounds: Int? {
        get {
            guard let string = keychain[Key.pbkdf2Rounds] else { return nil }
            return Int(string)
        }
        set {
            if let newValue = newValue {
                keychain[Key.pbkdf2Rounds] = String(newValue)
            } else {
                keychain[Key.pbkdf2Rounds] = nil
            }
        }
    }
}
