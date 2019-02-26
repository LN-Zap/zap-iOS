//
//  Zap
//
//  Created by Otto Suess on 23.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

enum Environment {
    static var allowFakeMnemonicConfirmation: Bool {
        return ProcessInfo.processInfo.environment["FAKE_MNEMONIC_CONF"] == "1"
    }

    static var fakeBiometricAuthentication: Bool {
        return ProcessInfo.processInfo.environment["FAKE_BIOMETRIC_AUTHENTICATION"] == "1"
    }
}
