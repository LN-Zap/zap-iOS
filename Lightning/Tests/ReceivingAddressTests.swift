//
//  BTCUtilTests
//
//  Created by Otto Suess on 10.10.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
@testable import Lightning
@testable import SwiftLnd
import XCTest

// swiftlint:disable force_try force_unwrapping
class ReceivingAddressTests: XCTestCase {
    func testNewAddressGetsSaved() {
        let expectation = XCTestExpectation(description: "Create Receiving Address")

        let testAddress = BitcoinAddress(string: "mwthp1qAAisrqMiKqZG7TMGAgMNJTg5hbD")!
        
        let mockApi = LightningApiMock(newAddress: testAddress)
        let mockPersistence = MockPersistence()
        let lightningService = LightningService(api: mockApi, persistence: mockPersistence)
        
        lightningService.transactionService.newAddress(with: .witnessPubkeyHash) { _ in
            XCTAssertEqual(try! ReceivingAddress.all(database: try! mockPersistence.connection()), [testAddress])
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
}
