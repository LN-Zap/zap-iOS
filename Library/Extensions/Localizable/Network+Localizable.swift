//
//  Zap
//
//  Created by Otto Suess on 05.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftBTC

extension Network: Localizable {
    public var localized: String {
        switch self {
        case .testnet:
            return "network.type.testnet".localized
        case .mainnet:
            return "network.type.mainnet".localized
        }
    }
}
