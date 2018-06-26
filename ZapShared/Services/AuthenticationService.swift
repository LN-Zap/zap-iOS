//
//  Zap
//
//  Created by Otto Suess on 08.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Foundation
import KeychainAccess

private let keychainPinKey = "hashedPin"
private let keychainPinLengthKey = "pinLength"

final class AuthenticationService {
    static let shared = AuthenticationService()

    private let keychain = Keychain(service: "com.jackmallers.zap")
    
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
    
    var didSetupPin: Bool {
        return keychain[keychainPinKey] != nil
    }
    
    private init() {}
    
    func setPin(_ pin: String) {
        hashedPin = pin.sha256()
        pinLength = pin.count
    }
    
    func isMatchingPin(_ pin: String) -> Bool {
        return pin.sha256() == hashedPin
    }
    
    func resetPin() {
        hashedPin = nil
        pinLength = nil
    }
}
