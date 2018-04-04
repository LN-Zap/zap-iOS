//
//  ZapTests
//
//  Created by Otto Suess on 26.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import XCTest
@testable import Zap

class AddressTypeTests: XCTestCase {
    
    func testLightningNode() {
        XCTAssertFalse(AddressType.lightningNode.isValidAddress("abcd123"))
        XCTAssertFalse(AddressType.lightningNode.isValidAddress("02f6725f9c1c40333b67faea92fd211c183050f28df32cac3f9d69685fe9665432"))
        XCTAssertTrue(AddressType.lightningNode.isValidAddress("02f6725f9c1c40333b67faea92fd211c183050f28df32cac3f9d69685fe9665432@104.198.32.198:"))
        XCTAssertTrue(AddressType.lightningNode.isValidAddress("02f6725f9c1c40333b67faea92fd211c183050f28df32cac3f9d69685fe9665432@104.198.32.198:9735"))
        XCTAssertTrue(AddressType.lightningNode.isValidAddress("02f6725f9c1c40333b67faea92fd211c183050f28df32cac3f9d69685fe9665432 104.198.32.198 9735"))
        XCTAssertTrue(AddressType.lightningNode.isValidAddress("02f6725f9c1c40333b67faea92fd211c183050f28df32cac3f9d69685fe9665432@104.198.32.198"))
        XCTAssertTrue(AddressType.lightningNode.isValidAddress("02f6725f9c1c40333b67faea92fd211c183050f28df32cac3f9d69685fe9665432   104.198.32.198"))

    }
}
