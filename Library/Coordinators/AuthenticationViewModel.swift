//
//  Zap
//
//  Created by Otto Suess on 08.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Foundation
import KeychainAccess

private let keychainPinKey = "hashedSaltPin"
private let keychainPinLengthKey = "pinLength"

final class AuthenticationViewModel: NSObject {
    @objc enum State: Int {
        case locked     // user has to enter a pin to unlock
        case timeLocked // user entered wrong pin to often and has to wait until unlock
        case unlocked   // wallet is unlocked
    }
    
    @objc public dynamic var state: State = .locked
    
    private let unlockTime: TimeInterval = 60
    
    private let keychain = Keychain(service: "com.jackmallers.zap.password").accessibility(.whenUnlocked)
    private var lastAuthenticationDate: Date?

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
        
        if !didSetupPin || Environment.skipPinFlow {
            state = .unlocked
        }
    }
    
    func hashPin(_ pin: String) -> String {
        let salt = "kZF86kneOPAm09Wpl6XOLixuyctCM/lK"
        return "\(salt)\(pin)".sha256()
    }
    
    func setPin(_ pin: String) {
        hashedPin = hashPin(pin)
        pinLength = pin.count
    }
    
    func isMatchingPin(_ pin: String) -> Bool {
        return hashPin(pin) == hashedPin
    }
    
    func didAuthenticate() {
        lastAuthenticationDate = Date()
        state = .unlocked
    }
    
    static func resetPin() {
        let viewModel = AuthenticationViewModel()
        viewModel.hashedPin = nil
        viewModel.pinLength = nil
    }
}
