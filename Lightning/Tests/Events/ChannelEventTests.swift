//
//  LightningTests
//
//  Created by 0 on 05.03.19.
//  Copyright © 2019 Zap. All rights reserved.
//

@testable import Lightning
import SQLite
import SwiftBTC
import SwiftLnd
import XCTest

// swiftlint:disable force_try implicitly_unwrapped_optional
class ChannelEventTests: XCTestCase {
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
        let node = LightningNode(pubKey: "PK", alias: "alias", color: "#ff00ff")
        let event = ChannelEvent(txHash: "hash", node: node, blockHeight: 1, type: .abandoned, fee: 22)

        try! event.insert(database: mockConnection)

        let events = try! ChannelEvent.events(database: mockConnection)

        XCTAssertEqual(events.count, 1)

        XCTAssertEqual(events.first?.txHash, "hash")
        XCTAssertEqual(events.first?.blockHeight, 1)
        XCTAssertEqual(events.first?.type, .abandoned)

        // alias and color are not saved
        XCTAssertEqual(events.first?.node, LightningNode(pubKey: "PK", alias: nil, color: nil))
        // fee is not saved
        XCTAssertNil(events.first?.fee)
    }
}
