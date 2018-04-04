//
//  Zap
//
//  Created by Otto Suess on 30.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Foundation

final class InputNumberFormatter {
    let unit: BitcoinUnit
    
    init(unit: BitcoinUnit) {
        self.unit = unit
    }
    
    func validate(_ input: String) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.usesGroupingSeparator = true

        if input == "" {
            return ""
        }
        if input == numberFormatter.decimalSeparator {
            return "0."
        }
        if input == "00"
            || unit == .satoshi && input.contains(numberFormatter.decimalSeparator) {
            return nil
        }
        
        let parts = input.components(separatedBy: numberFormatter.decimalSeparator)
        if parts.count > 2 {
            return nil
        } else if parts.count == 2 {
            let minimumFractionDigits = parts.last?.count ?? 0
            if minimumFractionDigits > unit.exponent {
                return nil
            }
            numberFormatter.minimumFractionDigits = minimumFractionDigits
        } else {
            numberFormatter.minimumFractionDigits = 0
        }
        
        if let satoshis = Satoshi.from(string: input, unit: unit),
            let result = numberFormatter.string(from: satoshis.convert(to: unit)) {
            
            if input.hasSuffix(numberFormatter.decimalSeparator) {
                return result + numberFormatter.decimalSeparator
            } else {
                return result
            }
        } else {
            return nil
        }
    }
}
