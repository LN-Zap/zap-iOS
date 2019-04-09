//
//  Zap
//
//  Created by Otto Suess on 08.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Foundation
import Lightning
import SwiftLnd

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

    private let unlockTime: TimeInterval = 30

    private var lastAuthenticationDate: Date?

    let timeLockStore = TimeLockStore()

    override init() {
        super.init()

        if Environment.skipPinFlow {
            state = .unlocked
        } else if timeLockStore.isLocked {
            state = .timeLocked
        } else if !PinStore.didSetupPin {
            state = .unlocked
        }
    }

    func authenticate(_ pin: String) -> Result<Success, AuthenticationError> {
        if PinStore.isCorrect(pin: pin) {
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

    private func stateAfterAppRestart() -> State {
        if timeLockStore.isLocked {
            return .timeLocked
        } else if PinStore.didSetupPin,
            let lastAuthenticationDate = lastAuthenticationDate,
            lastAuthenticationDate.addingTimeInterval(unlockTime) < Date() {
            return .locked
        }
        return .unlocked
    }

    func updateStateAfterAppRestart() {
        state = stateAfterAppRestart()
    }
}
