//
//  BTCUtil
//
//  Created by Otto Suess on 28.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

public enum BitcoinUnit: String, Codable {
    case bitcoin
    case milliBitcoin
    case bit
    case satoshi
    
    public var exponent: Int {
        switch self {
        case .bitcoin:
            return 8
        case .milliBitcoin:
            return 5
        case .bit:
            return 2
        case .satoshi:
            return 0
        }
    }
    
    private var minimumFractionDigits: Int {
        switch self {
        case .bit:
            return 2
        case .satoshi:
            return 0
        default:
            return 1
        }
    }
    
    public var symbol: String {
        switch self {
        case .bitcoin:
            return "BTC"
        case .milliBitcoin:
            return "mBTC"
        case .bit:
            return "bit"
        case .satoshi:
            return "sat"
        }
    }
    
    public var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = minimumFractionDigits
        numberFormatter.maximumFractionDigits = exponent
        numberFormatter.usesGroupingSeparator = true
        return numberFormatter
    }
}
