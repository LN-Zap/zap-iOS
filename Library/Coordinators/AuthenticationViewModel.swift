//
//  Zap
//
//  Created by Otto Suess on 08.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Foundation
import KeychainAccess
import Lightning
import SwiftLnd

private let keychainPinKey = "hashedSaltPin"
private let keychainPinLengthKey = "pinLength"
private let salt = "kZF86kneOPAm09Wpl6XOLixuyctCM/lK"

enum AuthenticationError: Error {
    case lockout
    case notAvailable
    case canceled
    case failed
    case unknown
    case useFallback
    case wrongPin
}

final class AuthenticationViewModel: NSObject {
    @objc enum State: Int {
        case locked     // user has to enter a pin to unlock
        case timeLocked // user entered wrong pin to often and has to wait until unlock
        case unlocked   // wallet is unlocked
    }
    
    @objc public dynamic var state = State.locked
    
    private let unlockTime: TimeInterval = 60
    
    private let keychain = Keychain(service: "com.jackmallers.zap.password").accessibility(.whenUnlocked)
    private var lastAuthenticationDate: Date?

    let timeLockStore = TimeLockStore()
    
    private var hashedPin: String? {
        get { return keychain[keychainPinKey] }
        set { keychain[keychainPinKey] = newValue }
    }
    
    private(set) var pinLength: Int? {
        get {
            guard let string = keychain[keychainPinLengthKey] else { return nil }
            return Int(string)
        }
        set {
            if let newValue = newValue {
                keychain[keychainPinLengthKey] = String(newValue)
            } else {
                keychain[keychainPinLengthKey] = nil
            }
        }
    }
    
    var isLocked: Bool {
        if !didSetupPin {
            return true
        } else if let lastAuthenticationDate = lastAuthenticationDate {
            return lastAuthenticationDate.addingTimeInterval(unlockTime) < Date()
        }
        return true
    }
    
    var didSetupPin: Bool {
        return keychain[keychainPinKey] != nil
    }
    
    override init() {
        super.init()

        if timeLockStore.isLocked {
            state = .timeLocked
        } else if !didSetupPin || Environment.skipPinFlow {
            state = .unlocked
        }
    }
    
    private func hashPin(_ pin: String) -> String {
        return "\(salt)\(pin)".sha256()
    }
    
    func setPin(_ pin: String) {
        hashedPin = hashPin(pin)
        pinLength = pin.count
    }
    
    func authenticate(_ pin: String) -> Result<Success> {
        if hashPin(pin) == hashedPin {
            didAuthenticate()
            return .success(Success())
        } else {
            timeLockStore.increase()
            
            if timeLockStore.isLocked {
                state = .timeLocked
                return .failure(AuthenticationError.lockout)
            } else {
                return .failure(AuthenticationError.wrongPin)
            }
        }
    }
    
    func didAuthenticate() {
        timeLockStore.reset()
        lastAuthenticationDate = Date()
        state = .unlocked
    }
}
