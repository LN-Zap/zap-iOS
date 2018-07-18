//
//  ZapTests
//
//  Created by Otto Suess on 30.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
@testable import Library
import XCTest

final class InputNumberFormatterTests: XCTestCase {
    // swiftlint:disable:next function_body_length
    func testInputs() {
        let fiat = FiatCurrency(currencyCode: "USD", symbol: "$", localized: "$", exchangeRate: 1)
        
        let data: [(String, Currency, String?)] = [
            ("1", Bitcoin(unit: .satoshi), "1"),
            ("1.", Bitcoin(unit: .satoshi), nil),
            ("1.0", Bitcoin(unit: .satoshi), nil),
            ("23456", Bitcoin(unit: .satoshi), "23,456"),
            ("", Bitcoin(unit: .bit), ""),
            ("100", Bitcoin(unit: .bit), "100"),
            ("100.00", Bitcoin(unit: .bit), "100.00"),
            ("1000", Bitcoin(unit: .bit), "1,000"),
            (".7777", Bitcoin(unit: .bit), nil),
            ("100.000", Bitcoin(unit: .bit), nil),
            ("100.0000000", Bitcoin(unit: .bit), nil),
            ("10000.", Bitcoin(unit: .bit), "10,000."),
            ("10000..", Bitcoin(unit: .bit), nil),
            ("8888.8", Bitcoin(unit: .bit), "8,888.8"),
            ("100000000", Bitcoin(unit: .bit), "100,000,000"),
            ("100.000", Bitcoin(unit: .milliBitcoin), "100.000"),
            ("100.00000", Bitcoin(unit: .milliBitcoin), "100.00000"),
            ("100.00001", Bitcoin(unit: .milliBitcoin), "100.00001"),
            ("100.000000", Bitcoin(unit: .milliBitcoin), nil),
            ("1000.00000", Bitcoin(unit: .milliBitcoin), "1,000.00000"),
            ("00", Bitcoin(unit: .bitcoin), nil),
            (".", Bitcoin(unit: .bitcoin), "0."),
            ("20567890", Bitcoin(unit: .bitcoin), "20,567,890"),
            ("20567890.12345678", Bitcoin(unit: .bitcoin), "20,567,890.12345678"),
            ("20567890.123456780", Bitcoin(unit: .bitcoin), nil),
            ("", fiat, ""),
            ("100", fiat, "100"),
            ("100.00", fiat, "100.00"),
            ("1000", fiat, "1,000"),
            (".7777", fiat, nil),
            ("100.000", fiat, nil),
            ("100.0000000", fiat, nil),
            ("10000.", fiat, "10,000."),
            ("10000..", fiat, nil),
            ("8888.8", fiat, "8,888.8"),
            ("100000000", fiat, "100,000,000"),
            (".0", Bitcoin(unit: .bitcoin), "0.0"),
            (".00", Bitcoin(unit: .bitcoin), "0.00"),
            (".000", Bitcoin(unit: .bitcoin), "0.000"),
            (".0000", Bitcoin(unit: .bitcoin), "0.0000"),
            (".00001", Bitcoin(unit: .bitcoin), "0.00001"),
            (".00010000", Bitcoin(unit: .bitcoin), "0.00010000"),
            (".00000000", Bitcoin(unit: .bitcoin), "0.00000000"),
            (".00000001", Bitcoin(unit: .bitcoin), "0.00000001"),
            (".000000001", Bitcoin(unit: .bitcoin), nil),
            (".0000", Bitcoin(unit: .milliBitcoin), "0.0000"),
            (".00001", Bitcoin(unit: .milliBitcoin), "0.00001"),
            (".000001", Bitcoin(unit: .milliBitcoin), nil),
            (".00", Bitcoin(unit: .bit), "0.00"),
            (".01", Bitcoin(unit: .bit), "0.01"),
            (".001", Bitcoin(unit: .bit), nil),
            (".", Bitcoin(unit: .satoshi), nil),
            (".0", Bitcoin(unit: .satoshi), nil),
            (".0", fiat, "0.0"),
            (".00", fiat, "0.00"),
            (".000", fiat, nil),
            (".0000", fiat, nil),
            (".00001", fiat, nil)
        ]
        
        for (input, currency, output) in data {
            let formatter = InputNumberFormatter(currency: currency)
            XCTAssertEqual(formatter.validate(input), output, "(\(input), \(currency) = \(String(describing: output)))")
        }
    }
}
