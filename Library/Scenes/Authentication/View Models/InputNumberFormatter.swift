//
//  Zap
//
//  Created by Otto Suess on 30.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import SwiftBTC

final class InputNumberFormatter {
    let currency: Currency
    
    init(currency: Currency) {
        self.currency = currency
    }
    
    func validate(_ input: String) -> String? {
        if let cryptoCurrency = currency as? Bitcoin {
            return validate(input, for: cryptoCurrency)
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
    
    private func validateFiat(_ input: String) -> String? {
        guard
            let numberFormatter = numberFormatter(for: input, exponent: 2),
            let decimalSeparator = numberFormatter.decimalSeparator
            else { return nil }

        if input.isEmpty {
            return ""
        } else if input == decimalSeparator {
            return "0\(decimalSeparator)"
        } else if input == "00" {
            return nil
        }
        
        if let number = numberFormatter.number(from: input),
            let result = numberFormatter.string(from: number) {
            
            if input.hasSuffix(decimalSeparator) {
                return result + decimalSeparator
            } else {
                return result
            }
        } else {
            return nil
        }
    }
    
    private func validate(_ input: String, for unit: Bitcoin) -> String? {
        guard
            let numberFormatter = numberFormatter(for: input, exponent: unit.maximumFractionDigits),
            let decimalSeparator = numberFormatter.decimalSeparator
            else { return nil }

        if input.isEmpty {
            return ""
        } else if unit == .satoshi && input.contains(decimalSeparator) {
            return nil
        } else if input == decimalSeparator {
            return "0\(decimalSeparator)"
        } else if input == "00" {
            return nil
        }
        
        let formatter = SatoshiFormatter(unit: unit)
        if let satoshis = formatter.satoshis(from: input),
            let result = numberFormatter.string(from: CurrencyConverter.convert(amount: satoshis, from: Bitcoin.satoshi, to: unit) as NSDecimalNumber) {
            
            if input.hasSuffix(decimalSeparator) {
                return result + decimalSeparator
            } else {
                return result
            }
        } else {
            return nil
        }
    }
}
