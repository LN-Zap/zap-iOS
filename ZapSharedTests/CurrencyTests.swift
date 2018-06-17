//
//  ZapTests
//
//  Created by Otto Suess on 31.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Foundation
import XCTest
@testable import ZapShared

final class CurrencyTests: XCTestCase {
    private let usd = FiatCurrency(currencyCode: "USD", symbol: "$", localized: "US Dollar", exchangeRate: 7000.00)
    private let eur = FiatCurrency(currencyCode: "EUR", symbol: "€", localized: "Euro", exchangeRate: 5500.00)
    
    func testSatoshisToCurrency() {
        let data: [(Currency, Satoshi, String)] = [
            (usd, 100_000_000, "$7,000.00"),
            (usd, 50_000_000, "$3,500.00"),
            (eur, 100_000_000, "€5,500.00"),
            (eur, 1, "€0.00"),
            (Bitcoin(unit: .bitcoin), 100_000_000, "1.0Ƀ"),
            (Bitcoin(unit: .satoshi), 1, "1s"),
            (Bitcoin(unit: .satoshi), 1234, "1,234s")
        ]
        
        for (currency, value, output) in data {
            XCTAssertEqual(currency.format(satoshis: value), output)
        }
    }
    
    func testFiatStringToSatoshis() {
        let data: [(FiatCurrency, String, Satoshi)] = [
            (usd, "$7,000.00", 100_000_000),
            (usd, "$7000.00", 100_000_000),
            (usd, "$3,500.00", 50_000_000),
            (eur, "€5,500.00", 100_000_000),
            (eur, "€0.00", 0)
        ]
        
        for (currency, string, output) in data {
            XCTAssertEqual(currency.satoshis(from: string), output, "(\(currency.currencyCode), \(string), \(output))")
        }
    }
}
