//
//  BTCUtilTests
//
//  Created by Otto Suess on 27.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

@testable import BTCUtil
import XCTest

class Base58Tests: XCTestCase {
    func testValidBase58() {
        let valid: [(String, String)] = [
            ("StV1DL6CwTryKyV", "hello world"),
            ("11StV1DL6CwTryKyV", "\0\0hello world"),
            ("", ""),
            ("Z", " "),
            ("n", "-"),
            ("q", "0"),
            ("r", "1"),
            ("4SU", "-1"),
            ("4k8", "11"),
            ("ZiCa", "abc"),
            ("3mJr7AoUXx2Wqd", "1234598760"),
            ("3yxU3u1igY8WkgtjK92fbJQCd4BZiiT1v25f", "abcdefghijklmnopqrstuvwxyz"),
            ("3sN2THZeE9Eh9eYrwkvZqNstbHGvrxSAM7gXUXvyFQP8XvQLUqNCS27icwUeDT7ckHm4FUHM2mTVh1vbLmk7y", "00000000000000000000000000000000000000000000000000000000000000")
        ]
        
        for (base58, output) in valid {
            let data = Base58.decode(base58)
            XCTAssertNotNil(data)
            if let data = data {
                XCTAssertEqual(String(data: data, encoding: .utf8), output)
            }
        }
    }
    
    func testInvalidBase58() {
        let invalid = [
            "0",
            "O",
            "I",
            "l",
            "3mJr0",
            "O3yxU",
            "3sNI",
            "4kl8",
            "0OIl",
            "!@#$%^&*()-_=+~`"]
        
        for base58 in invalid {
            let data = Base58.decode(base58)
            XCTAssertNil(data)
        }
    }
}
