//
//  Zap
//
//  Created by Otto Suess on 31.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Foundation

struct Bitcoin: Currency, Equatable {
    let unit: BitcoinUnit
    
    init(unit: BitcoinUnit) {
        self.unit = unit
    }
    
    var symbol: String {
        switch unit {
        case .bitcoin:
            return "Ƀ"
        case .milliBitcoin:
            return "mɃ"
        case .bit:
            return "ƀ"
        case .satoshi:
            return "s"
        }
    }
    
    var localized: String {
        return unit.localized
    }
    
    func format(_ satoshis: Satoshi) -> String? {
        return satoshis.format(unit: unit) + symbol
    }
}
