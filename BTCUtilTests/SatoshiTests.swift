//
//  BTCUtilTests
//
//  Created by Otto Suess on 28.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

@testable import BTCUtil
import XCTest

final class BitcoinUnitTests: XCTestCase {
    // swiftlint:disable:next large_tuple
    let inputs: [(BitcoinUnit, Satoshi, String)] = [
        (.satoshi, 1, "1"),
        (.satoshi, 100, "100"),
        (.satoshi, 1000, "1,000"),
        (.satoshi, 100000000, "100,000,000"),
        (.bit, 1, "0.01"),
        (.bit, 123, "1.23"),
        (.bit, 1234, "12.34"),
        (.bit, 123456789, "1,234,567.89"),
        (.milliBitcoin, 1, "0.00001"),
        (.milliBitcoin, 123, "0.00123"),
        (.milliBitcoin, 1234, "0.01234"),
        (.milliBitcoin, 100000, "1.0"),
        (.milliBitcoin, 123456789, "1,234.56789"),
        (.bitcoin, 1, "0.00000001"),
        (.bitcoin, 100, "0.000001"),
        (.bitcoin, 123456000, "1.23456"),
        (.bitcoin, 123456789, "1.23456789"),
        (.bitcoin, 100000000, "1.0"),
        (.bitcoin, 100000000000, "1,000.0"),
        (.bitcoin, 100000000001, "1,000.00000001")
    ]

    func testFormating() {
        for (unit, satoshis, string) in inputs {
            XCTAssertEqual(satoshis.format(unit: unit), string)
        }
    }
    
    func testSatoshiParsing() {
        for (unit, satoshis, string) in inputs {
            XCTAssertEqual(Satoshi.from(string: string, unit: unit), satoshis, "(\(unit), \(satoshis), \(string))")
        }
    }
    
    func testMilliSatoshiParsing() {
        let msat: [(BitcoinUnit, Satoshi, String)] = [
            (.satoshi, 1, "1.1"),
            (.satoshi, 100, "100.01"),
            (.bit, 111, "1.111"),
            (.bit, 0, "0.0010"),
            (.milliBitcoin, 0, "0.000001"),
            (.milliBitcoin, 1, "0.00001000001"),
            (.bitcoin, 1, "0.000000019"),
            (.bitcoin, 0, "0.000000009")
        ]
        
        for (unit, satoshis, string) in msat {
            XCTAssertEqual(Satoshi.from(string: string, unit: unit), satoshis)
        }
    }
    
    func testWithoutCommas() {
        let noCommas: [(BitcoinUnit, Satoshi, String)] = [
            (.satoshi, 1000, "1000"),
            (.bit, 123456789, "1234567.89"),
            (.milliBitcoin, 123456789, "1234.56789"),
            (.bitcoin, 100000000000, "1000.0"),
            (.bitcoin, 100000000001, "1000.00000001")
        ]
        
        for (unit, satoshis, string) in noCommas {
            XCTAssertEqual(Satoshi.from(string: string, unit: unit), satoshis)
        }
    }
    
    func testFromValue() {
        let data: [(NSDecimalNumber, BitcoinUnit, Satoshi)] = [
            (0, .satoshi, 0),
            (1, .satoshi, 1),
            (123456, .satoshi, 123456),
            (1, .bit, 100),
            (1.678, .bit, 167),
            (-1.678, .bit, -168),
            (1, .milliBitcoin, 100000),
            (1, .bitcoin, 100000000)
        ]
        
        for (input, unit, satoshis) in data {
            XCTAssertEqual(Satoshi.from(value: input, unit: unit), satoshis)
        }
    }
}
