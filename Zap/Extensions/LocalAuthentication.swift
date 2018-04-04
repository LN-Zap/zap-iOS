//
//  Zap
//
//  Created by Otto Suess on 10.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import LocalAuthentication

final class BiometricAuthentication {
    static func authenticate(callback: @escaping (Result<Void>) -> Void) {
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Use Passcode"
        
        var authError: NSError?
        let reasonString = "To access the secure data"

        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in
                if success {
                    callback(Result(value: ()))
                } else if let error = evaluateError {
                    let message = self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code)
                    callback(Result(error: LndError.localizedError(message)))
                }
            }
        } else if let error = authError {
            let message = self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code)
            callback(Result(error: LndError.localizedError(message)))
        }
    }

    static func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
        switch errorCode {
        case LAError.authenticationFailed.rawValue:
            return "The user failed to provide valid credentials"
        case LAError.appCancel.rawValue:
            return "Authentication was cancelled by application"
        case LAError.invalidContext.rawValue:
            return "The context is invalid"
        case LAError.notInteractive.rawValue:
            return "Not interactive"
        case LAError.passcodeNotSet.rawValue:
            return "Passcode is not set on the device"
        case LAError.systemCancel.rawValue:
            return "Authentication was cancelled by the system"
        case LAError.userCancel.rawValue:
            return "The user did cancel"
        case LAError.userFallback.rawValue:
            return "The user chose to use the fallback"
        case LAError.biometryNotAvailable.rawValue:
            return "Authentication could not start because the device does not support biometric authentication."
        case LAError.biometryLockout.rawValue:
            return "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."
        case LAError.biometryNotEnrolled.rawValue:
            return "Authentication could not start because the user has not enrolled in biometric authentication."
        default:
            return "Did not find error code on LAError object"
        }
    }
}
