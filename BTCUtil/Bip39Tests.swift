//
//  BTCUtilTests
//
//  Created by Otto Suess on 03.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

@testable import BTCUtil
import XCTest

class Bip39Tests: XCTestCase {
    func testValidWord() {
        XCTAssertTrue(Bip39.contains("abandon"))
        XCTAssertTrue(Bip39.contains("peasant"))
        XCTAssertTrue(Bip39.contains("zoo"))
    }
    
    func testInvalidWord() {
        XCTAssertFalse(Bip39.contains("bier"))
        XCTAssertFalse(Bip39.contains(""))
        XCTAssertFalse(Bip39.contains("\n"))
        XCTAssertFalse(Bip39.contains("abando"))
    }
}
