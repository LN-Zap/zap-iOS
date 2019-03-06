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
class CreateInvoiceEventTests: XCTestCase {
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
        let event = CreateInvoiceEvent(id: "idid", memo: "mem", amount: 393, date: date, expiry: date, paymentRequest: "pxcp")

        try! event.insert(database: mockConnection)

        let events = try! CreateInvoiceEvent.events(database: mockConnection)

        XCTAssertEqual(events.count, 1)

        XCTAssertEqual(events.first?.id, "idid")
        XCTAssertEqual(events.first?.memo, "mem")
        XCTAssertEqual(events.first?.amount, 393)
        XCTAssertEqual(events.first!.date.timeIntervalSinceReferenceDate, date.timeIntervalSinceReferenceDate, accuracy: 0.001)
        XCTAssertEqual(events.first!.expiry.timeIntervalSinceReferenceDate, date.timeIntervalSinceReferenceDate, accuracy: 0.001)
        XCTAssertEqual(events.first?.paymentRequest, "pxcp")
    }
}
