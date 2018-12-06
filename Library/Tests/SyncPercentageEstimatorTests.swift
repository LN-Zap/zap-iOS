//
//  LibraryTests
//
//  Created by Otto Suess on 05.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

@testable import Library
import XCTest

final class SyncPercentageEstimatorTests: XCTestCase {
    func testInitial() {
        let syncPercentEstimator = SyncPercentageEstimator(initialLndBlockHeight: 100, initialHeaderDate: Date(timeIntervalSince1970: 0))
        XCTAssertEqual(syncPercentEstimator.percentage(lndBlockHeight: 100, lndHeaderDate: Date(timeIntervalSince1970: 0), maxBlockHeight: 200), 0)
    }
    
    func testCompleted() {
        let syncPercentEstimator = SyncPercentageEstimator(initialLndBlockHeight: 100, initialHeaderDate: Date(timeIntervalSince1970: 0))
        XCTAssertEqual(syncPercentEstimator.percentage(lndBlockHeight: 200, lndHeaderDate: Date(), maxBlockHeight: 200), 1)
    }
    
    func testBlocks50Percent() {
        let syncPercentEstimator = SyncPercentageEstimator(initialLndBlockHeight: 100, initialHeaderDate: Date())
        XCTAssertEqual(syncPercentEstimator.percentage(lndBlockHeight: 150, lndHeaderDate: Date(), maxBlockHeight: 200), 0.5)
    }
    
    func testDate50Percent() {
        let syncPercentEstimator = SyncPercentageEstimator(initialLndBlockHeight: 100, initialHeaderDate: Date(timeIntervalSinceNow: -60 * 20))
        XCTAssertEqual(syncPercentEstimator.percentage(lndBlockHeight: 100, lndHeaderDate: Date(timeIntervalSinceNow: -60 * 10), maxBlockHeight: 100), 0.5)
    }
    
    func testBoth75Percent() {
        let syncPercentEstimator = SyncPercentageEstimator(initialLndBlockHeight: 100, initialHeaderDate: Date(timeIntervalSinceNow: -60 * 20))
        XCTAssertEqual(syncPercentEstimator.percentage(lndBlockHeight: 175, lndHeaderDate: Date(timeIntervalSinceNow: -60 * 5), maxBlockHeight: 200), 0.75)
    }
}
