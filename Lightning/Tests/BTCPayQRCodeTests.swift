//
//  ZapLightningTests
//
//  Created by Otto Suess on 29.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

@testable import Lightning
import XCTest

class BTCPayQRCodeTests: XCTestCase {
    func testParsingValidQRCode() {
        let qrCode = BTCPayQRCode(string: "config=https://testlnd1.btcpayserver.com/lnd-config/4210935981/lnd.config")
        XCTAssertEqual(qrCode?.configURL.absoluteString, "https://testlnd1.btcpayserver.com/lnd-config/4210935981/lnd.config")
    }

    func testParsingInvalidQRCode() {
        let qrCode = BTCPayQRCode(string: "https://testlnd1.btcpayserver.com/lnd-config/4210935981/lnd.config")
        XCTAssertNil(qrCode)
    }
}
