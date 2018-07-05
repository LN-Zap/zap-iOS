//
//  LibraryTests
//
//  Created by Otto Suess on 05.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
@testable import Library
import XCTest

class BitcoinTests: XCTestCase {
    func testValue() {
        let data: [(Bitcoin, Satoshi, NSDecimalNumber)] = [
            (Bitcoin(unit: .bitcoin), 100_000_000, 1),
            (Bitcoin(unit: .bitcoin), 10_000_000, 0.1),
            (Bitcoin(unit: .bitcoin), 1_000_000, 0.01),
            (Bitcoin(unit: .bitcoin), 100_000, 0.001),
            (Bitcoin(unit: .bitcoin), 10_000, 0.0001),
            (Bitcoin(unit: .bitcoin), 1_000, 0.00001),
            (Bitcoin(unit: .bitcoin), 100, 0.000001),
            (Bitcoin(unit: .bitcoin), 10, 0.0000001),
            (Bitcoin(unit: .bitcoin), 1, 0.00000001),
            
            (Bitcoin(unit: .bit), 100_000_000, 1_000_000),
            (Bitcoin(unit: .bit), 10_000_000, 100_000),
            (Bitcoin(unit: .bit), 1_000_000, 10_000),
            (Bitcoin(unit: .bit), 100_000, 1_000),
            (Bitcoin(unit: .bit), 10_000, 100),
            (Bitcoin(unit: .bit), 1_000, 10),
            (Bitcoin(unit: .bit), 100, 1),
            (Bitcoin(unit: .bit), 10, 0.1),
            (Bitcoin(unit: .bit), 1, 0.01),
            
            (Bitcoin(unit: .satoshi), 100_000_000, 100_000_000),
            (Bitcoin(unit: .satoshi), 10_000_000, 10_000_000),
            (Bitcoin(unit: .satoshi), 1_000_000, 1_000_000),
            (Bitcoin(unit: .satoshi), 100_000, 100_000),
            (Bitcoin(unit: .satoshi), 10_000, 10_000),
            (Bitcoin(unit: .satoshi), 1_000, 1_000),
            (Bitcoin(unit: .satoshi), 100, 100),
            (Bitcoin(unit: .satoshi), 10, 10),
            (Bitcoin(unit: .satoshi), 1, 1)
        ]
        for (currency, satoshis, result) in data {
            XCTAssertEqual(currency.value(satoshis: satoshis), result, "(\(currency), \(satoshis) = \(result)))")
        }
    }
}
