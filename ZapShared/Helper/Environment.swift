//
//  Zap
//
//  Created by Otto Suess on 23.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

enum Environment {
    static var isRunningTests: Bool {
        return ProcessInfo.processInfo.environment["IS_RUNNING_TESTS"] == "1"
    }
    
    static var skipPinFlow: Bool {
        return ProcessInfo.processInfo.environment["SKIP_PIN_FLOW"] == "1"
    }
    
    static var allowFakeMnemonicConfirmation: Bool {
        return ProcessInfo.processInfo.environment["FAKE_MNEMONIC_CONF"] == "1"
    }
}
