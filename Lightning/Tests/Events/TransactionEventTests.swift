//
//  LightningTests
//
//  Created by 0 on 05.03.19.
//  Copyright © 2019 Zap. All rights reserved.
//

@testable import Lightning
import SQLite
import SwiftBTC
import XCTest

// swiftlint:disable force_try force_unwrapping implicitly_unwrapped_optional
class TransactionEventTests: XCTestCase {
    override func setUp() {
        super.setUp()

        mockConnection = try! MockPersistence().connection()
    }

    override func tearDown() {
        mockConnection = nil

        super.tearDown()
    }

    var mockConnection: Connection!

    func testSaveLoad() {
        let date = Date()
        let address = BitcoinAddress(string: "mwthp1qAAisrqMiKqZG7TMGAgMNJTg5hbD")!

        let event = TransactionEvent(txHash: "hash", memo: "test memo", amount: 123, fee: 12, date: date, destinationAddresses: [address], blockHeight: 321, type: .unknown)
        try! event.insert(database: mockConnection)

        let events = try! TransactionEvent.events(database: mockConnection)

        XCTAssertEqual(events.count, 1)

        XCTAssertEqual(events.first?.txHash, "hash")
        XCTAssertEqual(events.first?.memo, "test memo")
        XCTAssertEqual(events.first?.amount, 123)
        XCTAssertEqual(events.first?.fee, 12)
        XCTAssertEqual(events.first!.date.timeIntervalSinceReferenceDate, date.timeIntervalSinceReferenceDate, accuracy: 0.001)
        XCTAssertEqual(events.first?.destinationAddresses, [address])
        XCTAssertEqual(events.first?.blockHeight, 321)
        XCTAssertEqual(events.first?.type, .unknown)
    }
}
