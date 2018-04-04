//
//  ZapTests
//
//  Created by Otto Suess on 30.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import XCTest
@testable import Zap

class InputNumberFormatterTests: XCTestCase {
    
    func testInputs() {
        let data: [(String, BitcoinUnit, String?)] = [
            ("1", .satoshi, "1"),
            ("1.", .satoshi, nil),
            ("1.0", .satoshi, nil),
            ("23456", .satoshi, "23,456"),
            ("", .bit, ""),
            ("100", .bit, "100"),
            ("100.00", .bit, "100.00"),
            ("1000", .bit, "1,000"),
            (".7777", .bit, nil),
            ("100.000", .bit, nil),
            ("100.0000000", .bit, nil),
            ("10000.", .bit, "10,000."),
            ("10000..", .bit, nil),
            ("8888.8", .bit, "8,888.8"),
            ("100000000", .bit, "100,000,000"),
            ("100.000", .milliBitcoin, "100.000"),
            ("100.00000", .milliBitcoin, "100.00000"),
            ("100.00001", .milliBitcoin, "100.00001"),
            ("100.000000", .milliBitcoin, nil),
            ("1000.00000", .milliBitcoin, "1,000.00000"),
            ("00", .bitcoin, nil),
            (".", .bitcoin, "0."),
            ("20567890", .bitcoin, "20,567,890"),
            ("20567890.12345678", .bitcoin, "20,567,890.12345678"),
            ("20567890.123456780", .bitcoin, nil)
        ]
        
        for (input, unit, output) in data {
            let formatter = InputNumberFormatter(unit: unit)
            XCTAssertEqual(formatter.validate(input), output, "(\(input), \(unit) = \(String(describing: output)))")
        }
    }
}
