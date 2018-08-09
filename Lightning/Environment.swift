//
//  Lightning
//
//  Created by Otto Suess on 29.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

enum Environment {
    static var isRunningTests: Bool {
        return ProcessInfo.processInfo.environment["IS_RUNNING_TESTS"] == "1"
    }
    
    static var useMockApi: Bool {
        return ProcessInfo.processInfo.environment["USE_MOCK_API"] == "1"
    }
}
