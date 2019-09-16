//
//  Library
//
//  Created by 0 on 18.07.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import KeychainAccess

extension Keychain {
    convenience init(serviceExtension: String) {
        let service = "\(Bundle.main.bundleIdentifier ?? "com.jackmallers.zap").\(serviceExtension)"
        self.init(service: service)
    }
}
