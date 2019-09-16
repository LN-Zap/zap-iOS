//
//  LightningTests
//
//  Created by Otto Suess on 13.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

@testable import Lightning
@testable import SwiftLnd
import XCTest

class DateEstimatorTests: XCTestCase {
    private func transactionWith(date: Date, blockHeight: Int) -> Transaction {
        return Transaction(id: "", amount: 0, date: date, fees: 0, destinationAddresses: [], blockHeight: blockHeight)
    }

    func testEstimation() {

        let transactions = [
            transactionWith(date: Date(timeIntervalSince1970: 10), blockHeight: 10),
            transactionWith(date: Date(timeIntervalSince1970: 20), blockHeight: 20),
            transactionWith(date: Date(timeIntervalSince1970: 30), blockHeight: 30),
            transactionWith(date: Date(timeIntervalSince1970: 50), blockHeight: 40),
            transactionWith(date: Date(timeIntervalSince1970: 60), blockHeight: 50)
        ]

        let dateEstimator = DateEstimator(transactions: transactions)

        XCTAssertEqual(dateEstimator.estimatedDate(forBlockHeight: 1), Date(timeIntervalSince1970: 10 - 9 * 10 * 60))
        XCTAssertEqual(dateEstimator.estimatedDate(forBlockHeight: 10), Date(timeIntervalSince1970: 10))
        XCTAssertEqual(dateEstimator.estimatedDate(forBlockHeight: 11), Date(timeIntervalSince1970: 11))
        XCTAssertEqual(dateEstimator.estimatedDate(forBlockHeight: 15), Date(timeIntervalSince1970: 15))
        XCTAssertEqual(dateEstimator.estimatedDate(forBlockHeight: 19), Date(timeIntervalSince1970: 19))
        XCTAssertEqual(dateEstimator.estimatedDate(forBlockHeight: 30), Date(timeIntervalSince1970: 30))
        XCTAssertEqual(dateEstimator.estimatedDate(forBlockHeight: 35), Date(timeIntervalSince1970: 40))
        XCTAssertEqual(dateEstimator.estimatedDate(forBlockHeight: 50), Date(timeIntervalSince1970: 60))
        XCTAssertEqual(dateEstimator.estimatedDate(forBlockHeight: 100), Date(timeIntervalSince1970: 60 + 50 * 10 * 60))
    }

    func testEmptyTransactions() {
        let transactions = [Transaction]()
        let dateEstimator = DateEstimator(transactions: transactions)

        XCTAssertEqual(dateEstimator.estimatedDate(forBlockHeight: 1), nil)
        XCTAssertEqual(dateEstimator.estimatedDate(forBlockHeight: 100), nil)
    }

    func testOneTransaction() {
        let transactions = [
            transactionWith(date: Date(timeIntervalSince1970: 1 * 10 * 60), blockHeight: 10)
        ]
        let dateEstimator = DateEstimator(transactions: transactions)

        XCTAssertEqual(dateEstimator.estimatedDate(forBlockHeight: 9), Date(timeIntervalSince1970: 0))
        XCTAssertEqual(dateEstimator.estimatedDate(forBlockHeight: 10), Date(timeIntervalSince1970: 1 * 10 * 60))
        XCTAssertEqual(dateEstimator.estimatedDate(forBlockHeight: 11), Date(timeIntervalSince1970: 2 * 10 * 60))
        XCTAssertEqual(dateEstimator.estimatedDate(forBlockHeight: 90), Date(timeIntervalSince1970: 81 * 10 * 60))
    }
}
