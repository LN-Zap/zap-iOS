//
//  LightningTests
//
//  Created by 0 on 06.03.19.
//  Copyright © 2019 Zap. All rights reserved.
//

@testable import Lightning
import SQLite
import SwiftBTC
import SwiftLnd
import XCTest

// swiftlint:disable force_try force_unwrapping implicitly_unwrapped_optional
class LightningPaymentEventTests: XCTestCase {
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
        let node = LightningNode(pubKey: "PK", alias: "alias", color: "#ff00ff")

        let event = LightningPaymentEvent(paymentHash: "hash", memo: "mem12", amount: 95, fee: 21, date: date, node: node)
        try! event.insert(database: mockConnection)

        let events = try! LightningPaymentEvent.events(database: mockConnection)

        XCTAssertEqual(events.count, 1)

        XCTAssertEqual(events.first?.paymentHash, "hash")
        XCTAssertEqual(events.first?.memo, "mem12")
        XCTAssertEqual(events.first?.amount, 95)
        XCTAssertEqual(events.first?.fee, 21)
        XCTAssertEqual(events.first!.date.timeIntervalSinceReferenceDate, date.timeIntervalSinceReferenceDate, accuracy: 0.001)

        // alias and color are not saved
        XCTAssertEqual(events.first?.node, LightningNode(pubKey: "PK", alias: nil, color: nil))
    }
}
