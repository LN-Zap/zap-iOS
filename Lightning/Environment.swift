//
//  Lightning
//
//  Created by Otto Suess on 29.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

enum Environment {
    static var useMockApi: Bool {
        return ProcessInfo.processInfo.environment["USE_MOCK_API"] == "1"
    }

    static var useUITestMockApi: Bool {
        return ProcessInfo.processInfo.environment["USE_UITEST_MOCK_API"] == "1"
    }

    static var traceDB: Bool {
        return ProcessInfo.processInfo.environment["TRACE_DB"] == "1"
    }
}
