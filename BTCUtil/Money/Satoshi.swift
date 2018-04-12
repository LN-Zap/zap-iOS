//
//  BTCUtil
//
//  Created by Otto Suess on 30.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

public typealias Satoshi = NSDecimalNumber

extension Satoshi {
    public static func from(value: NSDecimalNumber, unit: BitcoinUnit = .bitcoin) -> Satoshi {
        let handler = NSDecimalNumberHandler(
            roundingMode: .down,
            scale: 0,
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: false)

        return value
            .multiplying(byPowerOf10: unit.exponent)
            .rounding(accordingToBehavior: handler)
    }
    
    public static func from(string: String, unit: BitcoinUnit) -> Satoshi? {
        guard string != "" else { return 0 }
        var string = string
        
        if let groupingSeparator = Locale.autoupdatingCurrent.groupingSeparator {
            string = string.replacingOccurrences(of: groupingSeparator, with: "")
        }
        
        let satoshis = Satoshi(string: string, locale: Locale.autoupdatingCurrent)
        return Satoshi.from(value: satoshis, unit: unit)
    }
    
    public func convert(to unit: BitcoinUnit) -> NSDecimalNumber {
        return self.multiplying(byPowerOf10: -unit.exponent)
    }
    
    public func format(unit: BitcoinUnit) -> String {
        let number = convert(to: unit)
        return unit.numberFormatter.string(from: number) ?? ""
    }
}
