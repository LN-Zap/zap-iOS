//
//  Lightning
//
//  Created by 0 on 29.10.19.
//  Copyright © 2019 Zap. All rights reserved.
//

@testable import Lightning
import XCTest

class LNURLTests: XCTestCase {
    func testLNURLDecoding() {
        let string = "LNURL1DP68GURN8GHJ7UM9WFMXJCM99E3K7MF0V9CXJ0M385EKVCENXC6R2C35XVUKXEFCV5MKVV34X5EKZD3EV56NYD3HXQURZEPEXEJXXEPNXSCRVWFNV9NXZCN9XQ6XYEFHVGCXXCMYXYMNSERXFQ5FNS"

        let data = try! LNURL.decodeBech32(string: string).get() // swiftlint:disable:this force_try
        let decodedString = String(data: data, encoding: .utf8)
        XCTAssertEqual(decodedString, "https://service.com/api?q=3fc3645b439ce8e7f2553a69e5267081d96dcd340693afabe04be7b0ccd178df")
    }
}
