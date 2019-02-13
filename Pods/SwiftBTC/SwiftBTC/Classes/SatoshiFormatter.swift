//
//  SatoshiFormatter.swift
//  BigInt
//
//  Created by Otto Suess on 08.02.19.
//

import Foundation

public extension Bitcoin {
    public var minimumFractionDigits: Int {
        switch self {
        case .bit:
            return 2
        case .satoshi:
            return 0
        default:
            return 1
        }
    }
    
    public var maximumFractionDigits: Int {
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
}

public class SatoshiFormatter {
    public let unit: Bitcoin
    public var minimumFractionDigits: Int
    
    public var includeCurrencySymbol: Bool = true
    public var usesGroupingSeparator: Bool = true
    
    public init(unit: Bitcoin) {
        self.unit = unit
        minimumFractionDigits = unit.minimumFractionDigits
    }
    
    private func numberFormatter() -> NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = minimumFractionDigits
        numberFormatter.maximumFractionDigits = unit.maximumFractionDigits
        numberFormatter.usesGroupingSeparator = usesGroupingSeparator
        return numberFormatter
    }
    
    public func satoshis(from string: String) -> Satoshi? {
        guard !string.isEmpty else { return 0 }
        var string = string
        
        if let groupingSeparator = Locale.autoupdatingCurrent.groupingSeparator {
            string = string.replacingOccurrences(of: groupingSeparator, with: "")
        }
        
        if
            let satoshis = Satoshi(string: string, locale: Locale.current),
            satoshis.isNormal || satoshis.isZero {
            
            return CurrencyConverter.convert(amount: satoshis, from: unit, to: Bitcoin.satoshi)
        } else {
            return nil
        }
    }
    
    public func string(from satoshis: Satoshi) -> String? {
        let number = CurrencyConverter.convert(amount: satoshis, from: Bitcoin.satoshi, to: unit)
        var numberString = numberFormatter().string(from: number as NSDecimalNumber)
        if includeCurrencySymbol {
            numberString?.append(" \(unit.symbol)")
        }
        return numberString
    }
}
