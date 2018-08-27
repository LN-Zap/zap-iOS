//
//  Zap
//
//  Created by Otto Suess on 10.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import Lightning
import LocalAuthentication

enum BiometricAuthenticationError: Error {
    case lockout
    case notAvailable
    case canceled
    case failed
    case unknown
}

enum BiometricAuthentication {
    enum BiometricType {
        case none
        case touchID
        case faceID
    }
    
    static var type: BiometricType {
        #if targetEnvironment(simulator)
        return .faceID
        #else
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
            return .touchID
        }
        #endif
    }
    
    static func authenticate(callback: @escaping (Result<Success>) -> Void) {
        #if targetEnvironment(simulator)
        // display a fake local authentication view when run on simulator.
        let alertController = UIAlertController(title: "Authenticate", message: "Fake Biometric Authenticatyion", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "cancel", style: .cancel) { _ in callback(.failure(BiometricAuthenticationError.canceled)) })
        alertController.addAction(UIAlertAction(title: "authenticate", style: .default) { _ in callback(.success(Success())) })
        UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
        #else
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "scene.pin.biometric.fallback.title".localized
        
        var authError: NSError?
        let reasonString = "scene.pin.biometric.reason".localized
        
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in
                if success {
                    execute(callback, with: .success(Success()))
                } else if let error = evaluateError {
                    execute(callback, with: .failure(error(for: error)))
                }
            }
        } else if let error = authError {
            execute(callback, with: .failure(error(for: error)))
        }
        #endif
    }
    
    private static func execute(_ callback: @escaping (Result<Success>) -> Void, with result: Result<Success>) {
        DispatchQueue.main.async {
            callback(result)
        }
    }

    private static func error(for error: NSError) -> BiometricAuthenticationError {
        let messages: [Int32: BiometricAuthenticationError] = [
            kLAErrorAuthenticationFailed: .failed,
            kLAErrorAppCancel: .canceled,
            kLAErrorSystemCancel: .canceled,
            kLAErrorUserFallback: .canceled,
            kLAErrorUserCancel: .canceled,
            kLAErrorInvalidContext: .notAvailable,
            kLAErrorNotInteractive: .notAvailable,
            kLAErrorPasscodeNotSet: .notAvailable,
            kLAErrorBiometryNotAvailable: .notAvailable,
            kLAErrorBiometryNotEnrolled: .notAvailable,
            kLAErrorBiometryLockout: .lockout
        ]
        return messages[Int32(error.code)] ?? .unknown
    }
}
