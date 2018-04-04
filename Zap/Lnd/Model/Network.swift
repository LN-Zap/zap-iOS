//
//  Zap
//
//  Created by Otto Suess on 01.04.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

enum Network {
    case testnet
    case mainnet
    
    var localized: String {
        switch self {
        case .testnet:
            return "network.type.testnet".localized
        case .mainnet:
            return "network.type.mainnet".localized
        }
    }
}
