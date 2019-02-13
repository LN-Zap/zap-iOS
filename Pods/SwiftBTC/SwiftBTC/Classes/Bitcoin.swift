//
//  SwiftBTC
//
//  Created by Otto Suess on 31.03.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

public typealias Satoshi = Decimal

public enum Bitcoin: String, Equatable, Codable, CaseIterable {
    case bitcoin
    case milliBitcoin
    case bit
    case satoshi
}

extension Bitcoin: Currency {
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
    
    public var exchangeRate: Decimal {
        switch self {
        case .bitcoin:
            return 1
        case .milliBitcoin:
            return 1000
        case .bit:
            return 1000000
        case .satoshi:
            return 100000000
        }
    }
    
    // MARK: Unit Conversion
    
    public func value(satoshis: Satoshi) -> Decimal? {
        return CurrencyConverter.convert(amount: satoshis, from: Bitcoin.satoshi, to: self)
    }
    
    // MARK: String formatting
    
    public func format(satoshis: Satoshi) -> String? {
        let formatter = SatoshiFormatter(unit: self)
        formatter.includeCurrencySymbol = true
        return formatter.string(from: satoshis)
    }
    
    public func satoshis(from string: String) -> Satoshi? {
        let formatter = SatoshiFormatter(unit: self)
        formatter.includeCurrencySymbol = true
        return formatter.satoshis(from: string)
    }
    
    public func stringValue(satoshis: Satoshi) -> String? {
        let formatter = SatoshiFormatter(unit: self)
        formatter.includeCurrencySymbol = false
        formatter.minimumFractionDigits = 0
        formatter.usesGroupingSeparator = false
        return formatter.string(from: satoshis)
    }
}
