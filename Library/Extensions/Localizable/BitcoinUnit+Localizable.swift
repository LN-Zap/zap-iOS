//
//  Zap
//
//  Created by Otto Suess on 20.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import SwiftBTC

extension BitcoinUnit: Localizable {
    public var localized: String {
        switch self {
        case .bitcoin:
            return L10n.Unit.Bitcoin.btc
        case .milliBitcoin:
            return L10n.Unit.Bitcoin.mbtc
        case .bit:
            return L10n.Unit.Bitcoin.bit
        case .satoshi:
            return L10n.Unit.Bitcoin.satoshi
        }
    }
}
