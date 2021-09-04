//
//  LightningTests
//
//  Created by Otto Suess on 17.10.18.
//  Copyright © 2018 Zap. All rights reserved.
//

@testable import Library
@testable import Lightning
@testable import SwiftLnd
import XCTest

// swiftlint:disable force_unwrapping
final class EventDetailViewModelTests: XCTestCase {

    func testTransactionEventZeroFees() {
        let transaction = Transaction(
            id: "100",
            amount: 21005000,
            date: Date(),
            fees: 0,
            destinationAddresses: [],
            blockHeight: 400000
        )

        let event = TransactionEvent(transaction: transaction)!
        let eventType = HistoryEventType.transactionEvent(event)
        let viewModel = EventDetailViewModel(event: eventType)
        let configuration = viewModel.detailConfiguration()

        XCTAssertEqual(configuration.count, 5)
    }

    func testTransactionEventFees() {
        let transaction = Transaction(
            id: "100",
            amount: 21005000,
            date: Date(),
            fees: 10,
            destinationAddresses: [],
            blockHeight: 400000
        )

        let event = TransactionEvent(transaction: transaction)!
        let eventType = HistoryEventType.transactionEvent(event)
        let viewModel = EventDetailViewModel(event: eventType)
        let configuration = viewModel.detailConfiguration()

        XCTAssertEqual(configuration.count, 6)
        if
            case let .horizontalStackView(_, content) = configuration[3],
            case let .amountLabel(amount, _) = content[1] {
            XCTAssertEqual(amount, 10)
        } else {
            XCTFail("no fee label")
        }
    }
}
