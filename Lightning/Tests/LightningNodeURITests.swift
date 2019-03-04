//
//  LightningTests
//
//  Created by Otto Suess on 18.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

@testable import Lightning
import XCTest

class LightningNodeURITests: XCTestCase {
    func testLightningNode() {
        let valid: [String] = [
            "039cc950286a8fa99218283d1adc2456e0d5e81be558da77dd6e85ba9a1fff5ad3@34.200.252.146",
            "039cc950286a8fa99218283d1adc2456e0d5e81be558da77dd6e85ba9a1fff5ad3@34.200.252.146",
            "02f6725f9c1c40333b67faea92fd211c183050f28df32cac3f9d69685fe9665432@104.198.32.198:",
            "02f6725f9c1c40333b67faea92fd211c183050f28df32cac3f9d69685fe9665432@104.198.32.198:9735",
            "02f6725f9c1c40333b67faea92fd211c183050f28df32cac3f9d69685fe9665432 104.198.32.198 9735",
            "02f6725f9c1c40333b67faea92fd211c183050f28df32cac3f9d69685fe9665432@104.198.32.198",
            "02f6725f9c1c40333b67faea92fd211c183050f28df32cac3f9d69685fe9665432   104.198.32.198"
        ]

        for uri in valid {
            XCTAssertNotNil(LightningNodeURI(string: uri))
        }

        let invalid: [String] = [
            "abcd123",
            "02f6725f9c1c40333b67faea92fd211c183050f28df32cac3f9d69685fe9665432"
        ]

        for uri in invalid {
            XCTAssertNil(LightningNodeURI(string: uri))
        }
    }
}
