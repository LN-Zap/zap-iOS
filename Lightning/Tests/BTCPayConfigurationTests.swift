//
//  LightningTests
//
//  Created by Otto Suess on 23.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

@testable import Lightning
import SwiftLnd
import XCTest

class BTCPayConfigurationTests: XCTestCase {

    func testDecodeBTCPayConfiguration() {
        // swiftlint:disable force_unwrapping
        let data = "{\"configurations\":[{\"type\":\"grpc\",\"cryptoCode\":\"BTC\",\"host\":\"test.test.com\",\"port\":443,\"ssl\":true,\"certificateThumbprint\":null,\"macaroon\":\"02deadbeef0202deadbeef02\"}]}".data(using: .utf8)!
        
        let configuration = BTCPayConfiguration(data: data)
        
        XCTAssertNotNil(configuration)
        XCTAssertEqual(configuration?.configurations.count, 1)
        
        let item = configuration!.configurations.first!
        XCTAssertEqual(item.type, "grpc")
        XCTAssertEqual(item.cryptoCode, "BTC")
        XCTAssertEqual(item.host, "test.test.com")
        XCTAssertEqual(item.port, 443)
        XCTAssertEqual(item.ssl, true)
        XCTAssertEqual(item.certificateThumbprint, nil)
        XCTAssertEqual(item.macaroon, "02deadbeef0202deadbeef02")
    }
    
    func testMultipleItems() {
        let data = "{\"configurations\":[{\"type\":\"grpc\",\"cryptoCode\":\"BTC\",\"host\":\"test.test.com\",\"port\":443,\"ssl\":true,\"certificateThumbprint\":null,\"macaroon\":\"02deadbeef0202deadbeef02\"},{\"type\":\"rest\",\"cryptoCode\":\"BTC\",\"host\":\"test.test.com\",\"port\":443,\"ssl\":true,\"certificateThumbprint\":null,\"macaroon\":\"02deadbeef0202deadbeef02\"}]}".data(using: .utf8)!
        
        let configuration = BTCPayConfiguration(data: data)
        
        XCTAssertNotNil(configuration)
        XCTAssertEqual(configuration?.configurations.count, 2)
        
        let item = configuration!.configurations.first!
        XCTAssertEqual(item.type, "grpc")
    }
    
    func testGRPCAccessor() {
        let data = "{\"configurations\":[{\"type\":\"rest\",\"cryptoCode\":\"BTC\",\"host\":\"test.test.com\",\"port\":443,\"ssl\":true,\"certificateThumbprint\":null,\"macaroon\":\"02deadbeef0202deadbeef02\"},{\"type\":\"grpc\",\"cryptoCode\":\"BTC\",\"host\":\"test.test.com\",\"port\":443,\"ssl\":true,\"certificateThumbprint\":null,\"macaroon\":\"02deadbeef0202deadbeef02\"},{\"type\":\"rest\",\"cryptoCode\":\"BTC\",\"host\":\"test.test.com\",\"port\":443,\"ssl\":true,\"certificateThumbprint\":null,\"macaroon\":\"02deadbeef0202deadbeef02\"}]}".data(using: .utf8)!
        let configuration = BTCPayConfiguration(data: data)
        
        XCTAssertNotNil(configuration?.rpcConfiguration)
        XCTAssertNil(configuration?.rpcConfiguration?.certificate)
        XCTAssertEqual(configuration?.rpcConfiguration?.url.absoluteString, "test.test.com:443")
        XCTAssertEqual(configuration?.rpcConfiguration?.macaroon, Macaroon(hexadecimalString: "02deadbeef0202deadbeef02"))
    }
}
