//
//  LightningTests
//
//  Created by Otto Suess on 11.10.18.
//  Copyright © 2018 Zap. All rights reserved.
//

@testable import Lightning
import SwiftBTC
@testable import SwiftLnd
import XCTest

// swiftlint:disable force_try force_unwrapping
class TransactionServiceTests: XCTestCase {

    func testSendGetsSaved() {

        let txid = "abc"
        let amount: Satoshi = 1000
        let memo = "this is test memo."
        let fee: Satoshi = 25

        let mockPersistence = MockPersistence()
        let mockApi = LightningApiMock(sendCoins: txid)
        let testConnection = LightningConnection.remote(RPCCredentials.mock)
        let lightningService = LightningService(api: mockApi, walletId: "1", persistence: mockPersistence, connection: testConnection)
        lightningService.start()

        let testAddress = BitcoinAddress(string: "mwthp1qAAisrqMiKqZG7TMGAgMNJTg5hbD")!

        let bitcoinURI = BitcoinURI(address: testAddress, amount: nil, memo: memo, lightningFallback: nil)!

        let expectation = XCTestExpectation(description: "Send on chain transaction")

        lightningService.transactionService.sendCoins(bitcoinURI: bitcoinURI, amount: amount) { _ in
            mockApi.subscribeTransactionsCallback?(.success(Transaction(id: txid, amount: amount + fee, date: Date(), fees: fee, destinationAddresses: [testAddress], blockHeight: nil)))

            let transactions = try! TransactionEvent.events(database: mockPersistence.connection())
            XCTAssertEqual(transactions.count, 1)
            XCTAssertEqual(transactions.first?.amount, amount + fee)
            XCTAssertEqual(transactions.first?.type, .userInitiated)
            XCTAssertEqual(transactions.first?.memo, memo)
            XCTAssertEqual(transactions.first?.fee, fee)

            guard case .transactionEvent(let transactionEvent) = lightningService.historyService.events.first! else {
                fatalError("Missing transaction event")
            }

            XCTAssertEqual(transactionEvent.type, .userInitiated)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

}
