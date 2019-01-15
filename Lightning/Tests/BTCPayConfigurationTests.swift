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
    func testGRPCAccessor() {
        let data = "{\"configurations\":[{\"type\":\"rest\",\"cryptoCode\":\"BTC\",\"host\":\"test.test.com\",\"port\":443,\"ssl\":true,\"certificateThumbprint\":null,\"macaroon\":\"02deadbeef0202deadbeef02\"},{\"type\":\"grpc\",\"cryptoCode\":\"BTC\",\"host\":\"test.test.com\",\"port\":443,\"ssl\":true,\"certificateThumbprint\":null,\"macaroon\":\"02deadbeef0202deadbeef02\"},{\"type\":\"rest\",\"cryptoCode\":\"BTC\",\"host\":\"test.test.com\",\"port\":443,\"ssl\":true,\"certificateThumbprint\":null,\"macaroon\":\"02deadbeef0202deadbeef02\"}]}".data(using: .utf8)!
        let configuration = BTCPayRPCConfiguration(data: data)
        
        XCTAssertNotNil(configuration?.rpcConfiguration)
        XCTAssertNil(configuration?.rpcConfiguration.certificate)
        XCTAssertEqual(configuration?.rpcConfiguration.url.absoluteString, "test.test.com:443")
        XCTAssertEqual(configuration?.rpcConfiguration.macaroon, Macaroon(hexadecimalString: "02deadbeef0202deadbeef02"))
    }
}
