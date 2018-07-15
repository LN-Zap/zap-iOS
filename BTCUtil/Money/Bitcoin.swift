//
//  Zap
//
//  Created by Otto Suess on 31.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

public struct Bitcoin: Currency, Equatable, Codable {
    public let unit: BitcoinUnit
    
    public init(unit: BitcoinUnit) {
        self.unit = unit
    }
    
    public var symbol: String {
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
    
    public func format(value: NSDecimalNumber) -> String? {
        fatalError("not implemented")
    }
    
    public func format(satoshis: Satoshi) -> String? {
        return satoshis.format(unit: unit) + symbol
    }
    
    public func satoshis(from string: String) -> Satoshi? {
        return Satoshi.from(string: string, unit: unit)
    }
    
    public func value(satoshis: Satoshi) -> Decimal? {
        return satoshis.multiplying(byPowerOf10: -unit.exponent)
    }
    
    public func stringValue(satoshis: Satoshi) -> String? {
        guard let value = self.value(satoshis: satoshis) else { return nil }
        
        let numberFormatter = unit.numberFormatter
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.usesGroupingSeparator = false
        
        return numberFormatter.string(from: value as NSDecimalNumber)
    }
}
