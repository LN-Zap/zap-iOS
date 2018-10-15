//
//  LightningTests
//
//  Created by Otto Suess on 13.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

@testable import Lightning
import XCTest

class DateEstimatorTests: XCTestCase {
    private func transactionWith(date: Date, blockHeight: Int) -> TransactionEvent {
        return TransactionEvent(txHash: "", memo: "", amount: 0, fee: 0, date: date, destinationAddresses: [], blockHeight: blockHeight, type: .unknown)
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

        XCTAssertEqual(dateEstimator.estimatedDate(forBlockHeight: 1), nil)
        XCTAssertEqual(dateEstimator.estimatedDate(forBlockHeight: 10), Date(timeIntervalSince1970: 10))
        XCTAssertEqual(dateEstimator.estimatedDate(forBlockHeight: 11), Date(timeIntervalSince1970: 11))
        XCTAssertEqual(dateEstimator.estimatedDate(forBlockHeight: 15), Date(timeIntervalSince1970: 15))
        XCTAssertEqual(dateEstimator.estimatedDate(forBlockHeight: 19), Date(timeIntervalSince1970: 19))
        XCTAssertEqual(dateEstimator.estimatedDate(forBlockHeight: 30), Date(timeIntervalSince1970: 30))
        XCTAssertEqual(dateEstimator.estimatedDate(forBlockHeight: 35), Date(timeIntervalSince1970: 40))
        XCTAssertEqual(dateEstimator.estimatedDate(forBlockHeight: 50), Date(timeIntervalSince1970: 60))
        XCTAssertEqual(dateEstimator.estimatedDate(forBlockHeight: 100), nil)
    }
    
    func testEmptyTransactions() {
        let transactions = [TransactionEvent]()
        let dateEstimator = DateEstimator(transactions: transactions)
        
        XCTAssertEqual(dateEstimator.estimatedDate(forBlockHeight: 1), nil)
        XCTAssertEqual(dateEstimator.estimatedDate(forBlockHeight: 100), nil)
    }
    
    func testOneTransaction() {
        let transactions = [
            transactionWith(date: Date(timeIntervalSince1970: 10), blockHeight: 10)
        ]
        let dateEstimator = DateEstimator(transactions: transactions)
        
        XCTAssertEqual(dateEstimator.estimatedDate(forBlockHeight: 1), nil)
        XCTAssertEqual(dateEstimator.estimatedDate(forBlockHeight: 10), Date(timeIntervalSince1970: 10))
        XCTAssertEqual(dateEstimator.estimatedDate(forBlockHeight: 100), nil)
    }
}
