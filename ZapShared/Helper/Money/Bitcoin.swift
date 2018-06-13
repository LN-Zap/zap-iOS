//
//  Zap
//
//  Created by Otto Suess on 31.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Foundation

struct Bitcoin: Currency, Equatable, Codable {
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
    
    func format(value: NSDecimalNumber) -> String? {
        fatalError("not implemented")
    }
    
    func format(satoshis: Satoshi) -> String? {
        return satoshis.format(unit: unit) + symbol
    }
    
    func satoshis(from string: String) -> Satoshi? {
        return Satoshi.from(string: string, unit: unit)
    }
    
    func value(satoshis: Satoshi) -> NSDecimalNumber? {
        let handler = NSDecimalNumberHandler(
            roundingMode: .down,
            scale: 0,
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: false)
        
        return satoshis
            .multiplying(byPowerOf10: Int16(-unit.exponent))
            .rounding(accordingToBehavior: handler)
    }
    
    func stringValue(satoshis: Satoshi) -> String? {
        guard let value = self.value(satoshis: satoshis) else { return nil }
        
        let numberFormatter = unit.numberFormatter
        numberFormatter.usesGroupingSeparator = false
        
        return numberFormatter.string(from: value)
    }
}
