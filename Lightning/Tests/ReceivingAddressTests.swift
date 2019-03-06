//
//  LightningTests
//
//  Created by Otto Suess on 10.10.18.
//  Copyright © 2018 Zap. All rights reserved.
//

@testable import Lightning
import SwiftBTC
@testable import SwiftLnd
import XCTest

extension RPCCredentials {
    // swiftlint:disable:next force_unwrapping
    static var mock: RPCCredentials = RPCCredentials(certificate: nil, macaroon: Macaroon(hexadecimalString: "deadbeef")!, host: URL(string: "127.0.0.1")!)
}

// swiftlint:disable force_try force_unwrapping implicitly_unwrapped_optional
class ReceivingAddressTests: XCTestCase {

    override func setUp() {
        super.setUp()

        mockPersistence = MockPersistence()
    }

    override func tearDown() {
        mockPersistence = nil

        super.tearDown()
    }

    var mockPersistence: MockPersistence!
    let testAddress = ReceivingAddressTable(address: BitcoinAddress(string: "mwthp1qAAisrqMiKqZG7TMGAgMNJTg5hbD")!)
    let testConnection = LightningConnection.remote(RPCCredentials.mock)

    func testNewAddressGetsSaved() {
        let expectation = XCTestExpectation(description: "Create Receiving Address")

        let mockApi = LightningApiMock(newAddress: testAddress.address)
        let lightningService = LightningService(api: mockApi, walletId: "1", persistence: mockPersistence, connection: testConnection)

        lightningService.transactionService.newAddress(with: .witnessPubkeyHash) { [testAddress, mockPersistence] _ in
            XCTAssertEqual(try! ReceivingAddressTable.all(database: mockPersistence!.connection()), [testAddress])
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testSubscribeTransactionsWithReceivingAddress() {
        let mockApi = LightningApiMock()
        let lightningService = LightningService(api: mockApi, walletId: "1", persistence: mockPersistence, connection: testConnection)
        lightningService.start()

        try! testAddress.insert(database: try! mockPersistence.connection())

        let transaction = Transaction(id: "id", amount: 1, date: Date(timeIntervalSince1970: 123), fees: 1, destinationAddresses: [testAddress.address], blockHeight: nil)
        mockApi.subscribeTransactionsCallback?(.success(transaction))

        let events = try! TransactionEvent.events(database: mockPersistence.connection())
        XCTAssertEqual(events.first?.type, .userInitiated)
    }

    func testSubscribeTransactionsWithoutReceivingAddress() {
        let mockApi = LightningApiMock()
        let lightningService = LightningService(api: mockApi, walletId: "1", persistence: mockPersistence, connection: testConnection)
        lightningService.start()

        let transaction = Transaction(id: "id", amount: 1, date: Date(), fees: 1, destinationAddresses: [testAddress.address], blockHeight: nil)
        mockApi.subscribeTransactionsCallback?(.success(transaction))

        let events = try! TransactionEvent.events(database: mockPersistence.connection())
        XCTAssertEqual(events.first?.type, .unknown)
    }

    func testInitialTransactionWithReceivingAddress() {
        try! testAddress.insert(database: try! mockPersistence.connection())

        let transaction = Transaction(id: "id", amount: 1, date: Date(timeIntervalSince1970: 123), fees: 1, destinationAddresses: [testAddress.address], blockHeight: nil)
        let mockApi = LightningApiMock(transactions: [transaction])
        let lightningService = LightningService(api: mockApi, walletId: "1", persistence: mockPersistence, connection: testConnection)

        lightningService.historyService.update()

        let events = try! TransactionEvent.events(database: mockPersistence.connection())
        XCTAssertEqual(events.first?.type, .userInitiated)
    }

    func testInitialTransactionWithoutReceivingAddress() {
        let transaction = Transaction(id: "id", amount: 1, date: Date(timeIntervalSince1970: 123), fees: 1, destinationAddresses: [testAddress.address], blockHeight: nil)
        let mockApi = LightningApiMock(transactions: [transaction])
        let lightningService = LightningService(api: mockApi, walletId: "1", persistence: mockPersistence, connection: testConnection)

        lightningService.historyService.update()

        let events = try! TransactionEvent.events(database: mockPersistence.connection())
        XCTAssertEqual(events.first?.type, .unknown)
    }
}
