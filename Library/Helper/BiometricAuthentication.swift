//
//  Zap
//
//  Created by Otto Suess on 10.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import Lightning
import LocalAuthentication
import SwiftLnd

enum BiometricAuthentication {
    enum BiometricType {
        case none
        case touchID
        case faceID
    }

    static var type: BiometricType {
        #if targetEnvironment(simulator)
        if #available(iOS 13, *) {
            return .none
        } else {
            return Environment.fakeBiometricAuthentication
                ? .faceID
                : .none
        }
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
            @unknown default:
                return .none
            }
        } else {
            return .touchID
        }
        #endif
    }

    static func authenticate(completion: @escaping (Result<Success, AuthenticationError>) -> Void) {
        #if targetEnvironment(simulator)
        guard Environment.fakeBiometricAuthentication else {
            completion(.failure(AuthenticationError.notAvailable))
            return
        }
        // display a fake local authentication view when run on simulator.
        let alertController = UIAlertController(title: "Authenticate", message: "Fake Biometric Authentication", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "cancel", style: .cancel) { _ in completion(.failure(AuthenticationError.canceled)) })
        alertController.addAction(UIAlertAction(title: "authenticate", style: .default) { _ in completion(.success(Success())) })

        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = RootViewController()
        alertWindow.windowLevel = WindowLevel.fakeBiometricAuthentication
        alertWindow.makeKeyAndVisible()
        alertWindow.tintColor = UIColor.Zap.lightningOrange
        alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
        #else
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = L10n.Scene.Pin.Biometric.Fallback.title

        var authError: NSError?
        let reasonString = L10n.Scene.Pin.Biometric.reason

        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in
                if success {
                    execute(completion, with: .success(Success()))
                } else if let error = evaluateError {
                    execute(completion, with: .failure(authenticationError(for: error)))
                }
            }
        } else if let error = authError {
            execute(completion, with: .failure(authenticationError(for: error)))
        }
        #endif
    }

    private static func execute(_ completion: @escaping (Result<Success, AuthenticationError>) -> Void, with result: Result<Success, AuthenticationError>) {
        DispatchQueue.main.async {
            completion(result)
        }
    }

    private static func authenticationError(for error: Error) -> AuthenticationError {
        let messages: [Int32: AuthenticationError] = [
            kLAErrorAuthenticationFailed: .failed,
            kLAErrorAppCancel: .canceled,
            kLAErrorSystemCancel: .canceled,
            kLAErrorUserCancel: .canceled,
            kLAErrorUserFallback: .useFallback,
            kLAErrorInvalidContext: .notAvailable,
            kLAErrorNotInteractive: .notAvailable,
            kLAErrorPasscodeNotSet: .notAvailable,
            kLAErrorBiometryNotAvailable: .notAvailable,
            kLAErrorBiometryNotEnrolled: .notAvailable,
            kLAErrorBiometryLockout: .lockout
        ]
        return messages[Int32(error._code)] ?? .unknown
    }
}
