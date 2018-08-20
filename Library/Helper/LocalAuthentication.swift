//
//  Zap
//
//  Created by Otto Suess on 10.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import Lightning
import LocalAuthentication

enum BiometricAuthentication {
    enum BiometricType {
        case none
        case touchID
        case faceID
    }
    
    static var type: BiometricType {
        let context = LAContext()
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else { return .none }
        
        if #available(iOS 11.0, *) {
            switch context.biometryType {
            case .none:
                return .none
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            }
        } else {
            return  .touchID
        }
    }
    
    static func authenticate(callback: @escaping (Result<Success>) -> Void) {
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "scene.pin.biometric.fallback.title".localized
        
        var authError: NSError?
        let reasonString = "scene.pin.biometric.reason".localized

        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in
                if success {
                    execute(callback, with: .success(Success()))
                } else if let error = evaluateError {
                    let message = self.errorMessage(for: error._code)
                    execute(callback, with: .failure(LndApiError.localizedError(message)))
                }
            }
        } else if let error = authError {
            let message = self.errorMessage(for: error._code)
            execute(callback, with: .failure(LndApiError.localizedError(message)))
        }
    }
    
    private static func execute(_ callback: @escaping (Result<Success>) -> Void, with result: Result<Success>) {
        DispatchQueue.main.async {
            callback(result)
        }
    }

    private static func errorMessage(for errorCode: Int) -> String {
        let messages: [Int32: String] = [
            // TODO: simplify error messages & localize.
            kLAErrorAuthenticationFailed: "The user failed to provide valid credentials",
            kLAErrorAppCancel: "Authentication was cancelled by application",
            kLAErrorInvalidContext: "The context is invalid",
            kLAErrorNotInteractive: "Not interactive",
            kLAErrorPasscodeNotSet: "Passcode is not set on the device",
            kLAErrorSystemCancel: "Authentication was cancelled by the system",
            kLAErrorUserCancel: "The user did cancel",
            kLAErrorUserFallback: "The user chose to use the fallback",
            kLAErrorBiometryNotAvailable: "Authentication could not start because the device does not support biometric authentication.",
            kLAErrorBiometryLockout: "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times.",
            kLAErrorBiometryNotEnrolled: "Authentication could not start because the user has not enrolled in biometric authentication."
        ]
        return messages[Int32(errorCode)] ?? "Did not find error code on LAError object"
    }
}
