//
//  LibraryTests
//
//  Created by Christopher Pinski on 11/11/19.
//  Copyright © 2019 Zap. All rights reserved.
//

@testable import Library
@testable import Lightning
import SwiftBTC
@testable import SwiftLnd
import XCTest

final class MockBackupService: StaticChannelBackupServiceType {
    func save(data: Result<Data, LndApiError>, nodePubKey: String, fileName: String) {}
}

extension RPCCredentials {
    // swiftlint:disable:next force_unwrapping
    static var mock: RPCCredentials = RPCCredentials(certificate: nil, macaroon: Macaroon(hexadecimalString: "deadbeef")!, host: URL(string: "127.0.0.1")!)
}

// swiftlint:disable force_unwrapping
// swiftlint:disable implicitly_unwrapped_optional
final class SendViewModelTests: XCTestCase {

    private var mockService: LightningService!
    
    override func setUp() {
        super.setUp()
        
        let api = LightningApi(connection: MockLightningConnection())
        let testConnection = LightningConnection.remote(RPCCredentials.mock)
        
        mockService = LightningService(api: api, connection: testConnection, backupService: MockBackupService())
    }
    
    func testBitcoinTransactionSendStatus() {
        let expectation = self.expectation(description: "Send Status")
        
        let bitcoinURI = BitcoinURI(address: BitcoinAddress(string: "mv4rnyY3Su5gjcDNzbMLKBQkBicCtHUtFB")!, amount: 1234.0, memo: nil, lightningFallback: nil)
        let bitcoinInvoice = BitcoinInvoice(lightningPaymentRequest: nil, bitcoinURI: bitcoinURI)
        
        let sendViewModel = SendViewModel(invoice: bitcoinInvoice, lightningService: mockService)
                
        sendViewModel.sendStatus.observeNext { feeLimitPercent in
            XCTAssertEqual(nil, feeLimitPercent)
            expectation.fulfill()
        }.dispose(in: reactive.bag)
        
        sendViewModel.sendStatus.observeFailed { _ in
            XCTFail("Shouldn't observe a fee limit error")
            expectation.fulfill()
        }.dispose(in: reactive.bag)
        
        sendViewModel.determineSendStatus()
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testLightningPaymentUnderThresholdSendStatus() {
        let expectation = self.expectation(description: "Send Status")
        
        let paymentAmount: Satoshi = 90.0
        let feeAmount: Satoshi = 1.0
        let feePercentage: Decimal = 1.111
        
        let currentDate = Date()
        let paymentRequest = PaymentRequest(paymentHash: "c1dbb4c26256205edb85105422c30d6570c1f7e136574d2bc4c9a1d526b26a3a", destination: "test", amount: paymentAmount, memo: nil, date: currentDate, expiryDate: Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!, raw: "test", fallbackAddress: nil, network: .testnet)
        let bitcoinInvoice = BitcoinInvoice(lightningPaymentRequest: paymentRequest, bitcoinURI: nil)
        
        let sendViewModel = SendViewModel(invoice: bitcoinInvoice, lightningService: mockService)

        sendViewModel.fee.value = .element(.success(feeAmount))
        sendViewModel.feePercent = feePercentage
        
        sendViewModel.sendStatus.observeNext { feeLimitPercent in
            XCTAssertEqual(100, feeLimitPercent)
            expectation.fulfill()
        }.dispose(in: reactive.bag)
        
        sendViewModel.sendStatus.observeFailed { _ in
            XCTFail("Shouldn't observe a fee limit error")
            expectation.fulfill()
        }.dispose(in: reactive.bag)
        
        sendViewModel.determineSendStatus()
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testLightningPaymentUnderThresholdWithFeeGreaterThanPaymentSendStatus() {
        let expectation = self.expectation(description: "Send Status")
        
        let paymentAmount: Satoshi = 90.0
        let feeAmount: Satoshi = 95.0
        let feePercentage: Decimal = 105.556
        let userLightningPaymentFeeLimit = PaymentFeeLimitPercentage.one
        
        let currentDate = Date()
        let paymentRequest = PaymentRequest(paymentHash: "c1dbb4c26256205edb85105422c30d6570c1f7e136574d2bc4c9a1d526b26a3a", destination: "test", amount: paymentAmount, memo: nil, date: currentDate, expiryDate: Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!, raw: "test", fallbackAddress: nil, network: .testnet)
        let bitcoinInvoice = BitcoinInvoice(lightningPaymentRequest: paymentRequest, bitcoinURI: nil)
        
        let sendViewModel = SendViewModel(invoice: bitcoinInvoice, lightningService: mockService)

        Settings.shared.lightningPaymentFeeLimit.value = userLightningPaymentFeeLimit
        sendViewModel.fee.value = .element(.success(feeAmount))
        sendViewModel.feePercent = feePercentage
        
        sendViewModel.sendStatus.observeNext { _ in
            XCTFail("Shouldn't observe a fee limit success")
            expectation.fulfill()
        }.dispose(in: reactive.bag)
        
        sendViewModel.sendStatus.observeFailed { sendError in
            switch sendError {
            case .feeGreaterThanPayment(let feeInfo):
                XCTAssertEqual(feePercentage, feeInfo.feePercentage)
                XCTAssertEqual(nil, feeInfo.sendFeeLimitPercentage)
                XCTAssertEqual(userLightningPaymentFeeLimit.rawValue, feeInfo.userFeeLimitPercentage)
            case .feePercentageGreaterThanUserLimit:
                XCTFail("Shouldn't observe a fee percentage greater than user limit error")
            }
            expectation.fulfill()
        }.dispose(in: reactive.bag)
        
        sendViewModel.determineSendStatus()
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testLightningPaymentAtThresholdSendStatus() {
        let expectation = self.expectation(description: "Send Status")
        
        let paymentAmount: Satoshi = 100.0
        let feeAmount: Satoshi = 1.0
        let feePercentage: Decimal = 100.0
        
        let currentDate = Date()
        let paymentRequest = PaymentRequest(paymentHash: "c1dbb4c26256205edb85105422c30d6570c1f7e136574d2bc4c9a1d526b26a3a", destination: "test", amount: paymentAmount, memo: nil, date: currentDate, expiryDate: Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!, raw: "test", fallbackAddress: nil, network: .testnet)
        let bitcoinInvoice = BitcoinInvoice(lightningPaymentRequest: paymentRequest, bitcoinURI: nil)
        
        let sendViewModel = SendViewModel(invoice: bitcoinInvoice, lightningService: mockService)

        sendViewModel.fee.value = .element(.success(feeAmount))
        sendViewModel.feePercent = feePercentage
        
        sendViewModel.sendStatus.observeNext { feeLimitPercent in
            XCTAssertEqual(100, feeLimitPercent)
            expectation.fulfill()
        }.dispose(in: reactive.bag)
        
        sendViewModel.sendStatus.observeFailed { _ in
            XCTFail("Shouldn't observe a fee limit error")
            expectation.fulfill()
        }.dispose(in: reactive.bag)
        
        sendViewModel.determineSendStatus()
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testLightningPaymentWithFeeUnderUserLimit() {
        let expectation = self.expectation(description: "Send Status")
        
        let paymentAmount: Satoshi = 150.0
        let feeAmount: Satoshi = 1.0
        let feePercentage: Decimal = 0.667
        
        let currentDate = Date()
        let paymentRequest = PaymentRequest(paymentHash: "c1dbb4c26256205edb85105422c30d6570c1f7e136574d2bc4c9a1d526b26a3a", destination: "test", amount: paymentAmount, memo: nil, date: currentDate, expiryDate: Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!, raw: "test", fallbackAddress: nil, network: .testnet)
        let bitcoinInvoice = BitcoinInvoice(lightningPaymentRequest: paymentRequest, bitcoinURI: nil)
        
        let sendViewModel = SendViewModel(invoice: bitcoinInvoice, lightningService: mockService)

        Settings.shared.lightningPaymentFeeLimit.value = .one
        sendViewModel.fee.value = .element(.success(feeAmount))
        sendViewModel.feePercent = feePercentage
        
        sendViewModel.sendStatus.observeNext { feeLimitPercent in
            XCTAssertEqual(1, feeLimitPercent)
            expectation.fulfill()
        }.dispose(in: reactive.bag)
        
        sendViewModel.sendStatus.observeFailed { _ in
            XCTFail("Shouldn't observe a fee limit error")
            expectation.fulfill()
        }.dispose(in: reactive.bag)
        
        sendViewModel.determineSendStatus()
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testLightningPaymentWithFeeGreaterThanThresholdAndPaymentAmount() {
        let expectation = self.expectation(description: "Send Status")
        
        let paymentAmount: Satoshi = 150.0
        let feeAmount: Satoshi = 160.0
        let feePercentage: Decimal = 106.667
        let userLightningPaymentFeeLimit = PaymentFeeLimitPercentage.one
        
        let currentDate = Date()
        let paymentRequest = PaymentRequest(paymentHash: "c1dbb4c26256205edb85105422c30d6570c1f7e136574d2bc4c9a1d526b26a3a", destination: "test", amount: paymentAmount, memo: nil, date: currentDate, expiryDate: Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!, raw: "test", fallbackAddress: nil, network: .testnet)
        let bitcoinInvoice = BitcoinInvoice(lightningPaymentRequest: paymentRequest, bitcoinURI: nil)
        
        let sendViewModel = SendViewModel(invoice: bitcoinInvoice, lightningService: mockService)

        Settings.shared.lightningPaymentFeeLimit.value = userLightningPaymentFeeLimit
        sendViewModel.fee.value = .element(.success(feeAmount))
        sendViewModel.feePercent = feePercentage
        
        sendViewModel.sendStatus.observeNext { _ in
            XCTFail("Shouldn't observe a fee limit success")
            expectation.fulfill()
        }.dispose(in: reactive.bag)
        
        sendViewModel.sendStatus.observeFailed { sendError in
            switch sendError {
            case .feeGreaterThanPayment(let feeInfo):
                XCTAssertEqual(feePercentage, feeInfo.feePercentage)
                XCTAssertEqual(nil, feeInfo.sendFeeLimitPercentage)
                XCTAssertEqual(userLightningPaymentFeeLimit.rawValue, feeInfo.userFeeLimitPercentage)
            case .feePercentageGreaterThanUserLimit:
                XCTFail("Shouldn't observe a fee percentage greater than user limit error")
            }
            expectation.fulfill()
        }.dispose(in: reactive.bag)
        
        sendViewModel.determineSendStatus()
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testLightningPaymentWithFeeGreaterThanThresholdAndEqualToPaymentAmount() {
        let expectation = self.expectation(description: "Send Status")
        
        let paymentAmount: Satoshi = 150.0
        let feeAmount: Satoshi = 150.0
        let feePercentage: Decimal = 100.0
        let userLightningPaymentFeeLimit = PaymentFeeLimitPercentage.one
        
        let currentDate = Date()
        let paymentRequest = PaymentRequest(paymentHash: "c1dbb4c26256205edb85105422c30d6570c1f7e136574d2bc4c9a1d526b26a3a", destination: "test", amount: paymentAmount, memo: nil, date: currentDate, expiryDate: Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!, raw: "test", fallbackAddress: nil, network: .testnet)
        let bitcoinInvoice = BitcoinInvoice(lightningPaymentRequest: paymentRequest, bitcoinURI: nil)
        
        let sendViewModel = SendViewModel(invoice: bitcoinInvoice, lightningService: mockService)

        Settings.shared.lightningPaymentFeeLimit.value = .one
        sendViewModel.fee.value = .element(.success(feeAmount))
        sendViewModel.feePercent = feePercentage
        
        sendViewModel.sendStatus.observeNext { _ in
            XCTFail("Shouldn't observe a fee limit success")
            expectation.fulfill()
        }.dispose(in: reactive.bag)
        
        sendViewModel.sendStatus.observeFailed { sendError in
            switch sendError {
            case .feeGreaterThanPayment(let feeInfo):
                XCTAssertEqual(feePercentage, feeInfo.feePercentage)
                XCTAssertEqual(nil, feeInfo.sendFeeLimitPercentage)
                XCTAssertEqual(userLightningPaymentFeeLimit.rawValue, feeInfo.userFeeLimitPercentage)
            case .feePercentageGreaterThanUserLimit:
                XCTFail("Shouldn't observe a fee percentage greater than user limit error")
            }
            expectation.fulfill()
        }.dispose(in: reactive.bag)
        
        sendViewModel.determineSendStatus()
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testLightningPaymentWithFeePercentageGreaterThanUserLimit() {
        let expectation = self.expectation(description: "Send Status")
        
        let paymentAmount: Satoshi = 300
        let feeAmount: Satoshi = 100.0
        let feePercentage: Decimal = 33.333
        let userLightningPaymentFeeLimit = PaymentFeeLimitPercentage.three
        
        let currentDate = Date()
        let paymentRequest = PaymentRequest(paymentHash: "c1dbb4c26256205edb85105422c30d6570c1f7e136574d2bc4c9a1d526b26a3a", destination: "test", amount: paymentAmount, memo: nil, date: currentDate, expiryDate: Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!, raw: "test", fallbackAddress: nil, network: .testnet)
        let bitcoinInvoice = BitcoinInvoice(lightningPaymentRequest: paymentRequest, bitcoinURI: nil)
        
        let sendViewModel = SendViewModel(invoice: bitcoinInvoice, lightningService: mockService)

        Settings.shared.lightningPaymentFeeLimit.value = userLightningPaymentFeeLimit
        sendViewModel.fee.value = .element(.success(feeAmount))
        sendViewModel.feePercent = feePercentage
        
        sendViewModel.sendStatus.observeNext { _ in
            XCTFail("Shouldn't observe a fee limit success")
            expectation.fulfill()
        }.dispose(in: reactive.bag)
        
        sendViewModel.sendStatus.observeFailed { sendError in
            switch sendError {
            case .feeGreaterThanPayment:
                XCTFail("Shouldn't observe a fee greater than payment error")
            case .feePercentageGreaterThanUserLimit(let feeInfo):
                XCTAssertEqual(feePercentage, feeInfo.feePercentage)
                XCTAssertEqual(100, feeInfo.sendFeeLimitPercentage)
                XCTAssertEqual(userLightningPaymentFeeLimit.rawValue, feeInfo.userFeeLimitPercentage)
            }
            expectation.fulfill()
        }.dispose(in: reactive.bag)
        
        sendViewModel.determineSendStatus()
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testLightningPaymentWithUserLimitNone() {
        let expectation = self.expectation(description: "Send Status")
        
        let paymentAmount: Satoshi = 200.0
        let feeAmount: Satoshi = 100.0
        let feePercentage: Decimal = 50.0
        
        let currentDate = Date()
        let paymentRequest = PaymentRequest(paymentHash: "c1dbb4c26256205edb85105422c30d6570c1f7e136574d2bc4c9a1d526b26a3a", destination: "test", amount: paymentAmount, memo: nil, date: currentDate, expiryDate: Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!, raw: "test", fallbackAddress: nil, network: .testnet)
        let bitcoinInvoice = BitcoinInvoice(lightningPaymentRequest: paymentRequest, bitcoinURI: nil)
        
        let sendViewModel = SendViewModel(invoice: bitcoinInvoice, lightningService: mockService)

        Settings.shared.lightningPaymentFeeLimit.value = .zero
        sendViewModel.fee.value = .element(.success(feeAmount))
        sendViewModel.feePercent = feePercentage
        
        sendViewModel.sendStatus.observeNext { feeLimitPercent in
            XCTAssertEqual(nil, feeLimitPercent)
            expectation.fulfill()
        }.dispose(in: reactive.bag)
        
        sendViewModel.sendStatus.observeFailed { _ in
            XCTFail("Shouldn't observe a fee limit error")
            expectation.fulfill()
        }.dispose(in: reactive.bag)
        
        sendViewModel.determineSendStatus()
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
}
