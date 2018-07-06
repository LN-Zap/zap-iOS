//
//  BTCUtilTests
//
//  Created by Otto Suess on 10.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

@testable import BTCUtil
import XCTest

final class BitcoinURITests: XCTestCase {
    // swiftlint:disable:next large_tuple
    let tests: [(String, String, Satoshi?, String?)] = [
        ("bitcoin:mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p", "mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p", nil, nil),
        ("bitcoin:mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p?message=Luke-Jr", "mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p", nil, "Luke-Jr"),
        ("bitcoin:mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p?amount=20.3&message=Luke-Jr", "mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p", 2030000000, "Luke-Jr"),
        ("bitcoin:mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p?amount=50&message=Donation%20for%20project%20xyz", "mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p", 5000000000, "Donation for project xyz")
    ]

    func testBitcoinURI() {
        for (uriString, address, amount, memo) in tests {
            XCTAssertEqual(BitcoinURI(address: address, amount: amount, memo: memo)?.stringValue, uriString)
        }
    }
    
    func testInitWithString() {
        for (uriString, address, amount, memo) in tests {
            let uri = BitcoinURI(string: uriString)
            XCTAssertEqual(uri?.address, address)
            XCTAssertEqual(uri?.amount, amount)
            XCTAssertEqual(uri?.memo, memo)
        }
    }
}
