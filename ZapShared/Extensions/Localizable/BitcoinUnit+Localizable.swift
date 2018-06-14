//
//  Zap
//
//  Created by Otto Suess on 20.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Foundation

extension BitcoinUnit: Localizable {
    public var localized: String {
        switch self {
        case .bitcoin:
            return "unit.bitcoin.btc".localized
        case .milliBitcoin:
            return "unit.bitcoin.mbtc".localized
        case .bit:
            return "unit.bitcoin.bit".localized
        case .satoshi:
            return "unit.bitcoin.satoshi".localized
        }
    }
}
