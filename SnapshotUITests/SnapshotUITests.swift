//
//  SnapshotUITests
//
//  Created by 0 on 21.03.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import SimulatorStatusMagic
import XCTest

class SnapshotUITests: XCTestCase {
    var app: XCUIApplication! // swiftlint:disable:this implicitly_unwrapped_optional

    override func setUp() {
        super.setUp()

        continueAfterFailure = false

        app = XCUIApplication()
        app.launchEnvironment = [
            "USE_UITEST_MOCK_API": "1",
            "SKIP_PIN_FLOW": "1"
        ]
        setupSnapshot(app)

        SDStatusBarManager.sharedInstance()?.enableOverrides()

        app.launch()
    }

    func testWallet() {
        snapshot("10_Wallet")
    }

    func testHistory() {
        app.tabBars.buttons.element(boundBy: 1).tap()
        snapshot("20_History")
    }

    func testChannels() {
        app.tabBars.buttons.element(boundBy: 2).tap()
        app.tables.cells.element(boundBy: 4).tap()
        snapshot("30_Channels")
    }

    func testReceive() {
        app.buttons.element(boundBy: 6).tap()
        app.buttons.element(boundBy: 4).tap()
        app.buttons["1"].tap()
        app.buttons["0"].tap()
        app.buttons["0"].tap()
        app.buttons["0"].tap()
        snapshot("40_Receive")
    }
}
