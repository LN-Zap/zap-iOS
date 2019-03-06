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
class FailedPaymentEventTests: XCTestCase {
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
        let node = ConnectedNodeTable(pubKey: "PK", alias: "alias", color: "#ff00ff")
        let address = BitcoinAddress(string: "mwthp1qAAisrqMiKqZG7TMGAgMNJTg5hbD")!

        let event = FailedPaymentEvent(paymentHash: "ahsh", memo: "meme2", amount: 959, date: date, expiry: date, fallbackAddress: address, paymentRequest: "abcss", node: node)
        try! event.insert(database: mockConnection)

        let events = try! FailedPaymentEvent.events(database: mockConnection)

        XCTAssertEqual(events.count, 1)

        XCTAssertEqual(events.first?.paymentHash, "ahsh")
        XCTAssertEqual(events.first?.memo, "meme2")
        XCTAssertEqual(events.first?.amount, 959)
        XCTAssertEqual(events.first!.date.timeIntervalSinceReferenceDate, date.timeIntervalSinceReferenceDate, accuracy: 0.001)
        XCTAssertEqual(events.first!.expiry.timeIntervalSinceReferenceDate, date.timeIntervalSinceReferenceDate, accuracy: 0.001)
        XCTAssertEqual(events.first?.fallbackAddress, address)
        XCTAssertEqual(events.first?.paymentRequest, "abcss")
        XCTAssertEqual(events.first?.node, ConnectedNodeTable(pubKey: "PK", alias: nil, color: nil))
    }
}
