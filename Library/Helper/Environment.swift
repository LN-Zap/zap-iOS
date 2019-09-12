//
//  Zap
//
//  Created by Otto Suess on 23.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

enum Environment {
    static var localSimnet: Bool {
        return ProcessInfo.processInfo.environment["LOCAL_SIMNET"] == "1"
    }

    static var useUITestMockApi: Bool {
        return ProcessInfo.processInfo.environment["USE_UITEST_MOCK_API"] == "1"
    }

    static var skipPinFlow: Bool {
        return ProcessInfo.processInfo.environment["SKIP_PIN_FLOW"] == "1"
    }

    static var fakeBiometricAuthentication: Bool {
        return ProcessInfo.processInfo.environment["FAKE_BIOMETRIC_AUTHENTICATION"] == "1"
    }
}
