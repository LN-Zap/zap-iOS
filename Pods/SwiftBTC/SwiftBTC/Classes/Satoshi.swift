//
//  SwiftBTC
//
//  Created by Otto Suess on 30.03.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

public typealias Satoshi = Decimal

extension Satoshi {
    public static func from(value: Decimal, unit: BitcoinUnit = .bitcoin) -> Satoshi {
        var approximate = value.multiplying(byPowerOf10: unit.exponent)
        var rounded = Decimal()
        NSDecimalRound(&rounded, &approximate, 0, .bankers)
        return rounded
    }
    
    public static func from(string: String, unit: BitcoinUnit) -> Satoshi? {
        guard !string.isEmpty else { return 0 }
        var string = string
        
        if let groupingSeparator = Locale.autoupdatingCurrent.groupingSeparator {
            string = string.replacingOccurrences(of: groupingSeparator, with: "")
        }
        
        if
            let satoshis = Satoshi(string: string, locale: Locale.current),
            satoshis.isNormal || satoshis.isZero {
            return Satoshi.from(value: satoshis, unit: unit)
        } else {
            return nil
        }
    }
    
    public func convert(to unit: BitcoinUnit) -> Decimal {
        return self.multiplying(byPowerOf10: -unit.exponent)
    }
    
    public func format(unit: BitcoinUnit) -> String {
        let number = convert(to: unit)
        return unit.numberFormatter.string(from: number as NSDecimalNumber) ?? ""
    }
}
