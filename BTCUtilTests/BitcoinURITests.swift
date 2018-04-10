//
//  BTCUtilTests
//
//  Created by Otto Suess on 10.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

@testable import BTCUtil
import XCTest

class BitcoinURITests: XCTestCase {
    func testBitcoinURI() {
        XCTAssertEqual(BitcoinURI.from(address: "175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W"), "bitcoin:175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W")
        XCTAssertEqual(BitcoinURI.from(address: "175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W", message: "Luke-Jr"), "bitcoin:175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W?message=Luke-Jr")
        XCTAssertEqual(BitcoinURI.from(address: "175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W", amount: 2030000000, message: "Luke-Jr"), "bitcoin:175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W?amount=20.3&message=Luke-Jr")
        XCTAssertEqual(BitcoinURI.from(address: "175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W", amount: 5000000000, message: "Donation for project xyz"), "bitcoin:175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W?amount=50&message=Donation%20for%20project%20xyz")
    }
}
