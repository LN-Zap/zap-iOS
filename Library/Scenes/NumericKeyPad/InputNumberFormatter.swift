//
//  Zap
//
//  Created by Otto Suess on 30.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Foundation

final class InputNumberFormatter {
    let currency: Currency
    
    init(currency: Currency) {
        self.currency = currency
    }
    
    func validate(_ input: String) -> String? {
        if let bitcoin = currency as? Bitcoin {
            return validate(input, for: bitcoin.unit)
        } else {
            return validateFiat(input)
        }
    }
    
    private func numberFormatter(for input: String, exponent: Int) -> NumberFormatter? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.usesGroupingSeparator = true
        
        let parts = input.components(separatedBy: numberFormatter.decimalSeparator)
        if parts.count > 2 {
            return nil
        } else if parts.count == 2 {
            let minimumFractionDigits = parts.last?.count ?? 0
            if minimumFractionDigits > exponent {
                return nil
            }
            numberFormatter.minimumFractionDigits = minimumFractionDigits
        } else {
            numberFormatter.minimumFractionDigits = 0
        }

        return numberFormatter
    }
    
    // TODO: remove duplicate code
    private func validateFiat(_ input: String) -> String? {
        guard let numberFormatter = numberFormatter(for: input, exponent: 2) else { return nil }
        
        if input == "" {
            return ""
        } else if input == numberFormatter.decimalSeparator {
            return "0."
        } else if input == "00" {
            return nil
        }
        
        if let number = numberFormatter.number(from: input),
            let result = numberFormatter.string(from: number) {
            
            if input.hasSuffix(numberFormatter.decimalSeparator) {
                return result + numberFormatter.decimalSeparator
            } else {
                return result
            }
        } else {
            return nil
        }
    }
    
    private func validate(_ input: String, for unit: BitcoinUnit) -> String? {
        guard let numberFormatter = numberFormatter(for: input, exponent: unit.exponent) else { return nil }

        if input == "" {
            return ""
        } else if input == numberFormatter.decimalSeparator {
            return "0."
        } else if input == "00" || unit == .satoshi && input.contains(numberFormatter.decimalSeparator) {
            return nil
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
