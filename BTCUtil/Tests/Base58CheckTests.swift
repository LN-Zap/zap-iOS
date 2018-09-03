//
//  BTCUtilTests
//
//  Created by Otto Suess on 28.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

@testable import BTCUtil
import XCTest

final class Base58CheckTests: XCTestCase {
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
            let result = Base58Check.checkDecode(input)
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
            let result = Base58Check.checkDecode(input)
            XCTAssertNil(result)
            
        }
    }
}
