//
//  Lightning
//
//  Created by 0 on 17.07.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import SwiftBTC

enum BuildConfiguration {
    static var network: Network {
        if Bundle.main.bundleIdentifier == "com.jackmallers.zap.mainnet" {
            return .mainnet
        } else {
            return .testnet
        }
    }
}
