//
//  BTCUtilTests
//
//  Created by Otto Suess on 27.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

@testable import BTCUtil
import XCTest

final class Base58Tests: XCTestCase {
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
    
    func testValidBase58Check() {
        let decodeTests: [(String, (Int, String)?)] = [
            ("3MNQE1X", (20, "")),
            ("B2Kr6dBE", (20, " ")),
            ("B3jv1Aft", (20, "-")),
            ("B482yuaX", (20, "0")),
            ("B4CmeGAC", (20, "1")),
            ("mM7eUf6kB", (20, "-1")),
            ("mP7BMTDVH", (20, "11")),
            ("4QiVtDjUdeq", (20, "abc")),
            ("ZmNb8uQn5zvnUohNCEPP", (20, "1234598760")),
            ("K2RYDcKfupxwXdWhSAxQPCeiULntKm63UXyx5MvEH2", (20, "abcdefghijklmnopqrstuvwxyz")),
            ("bi1EWXwJay2udZVxLJozuTb8Meg4W9c6xnmJaRDjg6pri5MBAxb9XwrpQXbtnqEoRV5U2pixnFfwyXC8tRAVC8XxnjK", (20, "00000000000000000000000000000000000000000000000000000000000000"))
        ]
        
        for (input, output) in decodeTests {
            let result = Base58.checkDecode(input)
            XCTAssertNotNil(result)
            if let (version, payload) = result,
                let (expectedVersion, expectedPayload) = output {
                XCTAssertEqual(version, expectedVersion)
                XCTAssertEqual(String(data: payload, encoding: .utf8), expectedPayload)
                
            }
        }
    }
    
    func testInvalidBase58Check() {
        let decodeTests: [String] = [
            "1HbfPXavLn1fyB8dAf4Nv6whphZ7P4NsYQ",
            "3MNQE1Y",
            "",
            "1234"
        ]
        
        for input in decodeTests {
            let result = Base58.checkDecode(input)
            XCTAssertNil(result)
            
        }
    }
}
