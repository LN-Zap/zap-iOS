//
//  BTCUtilTests
//
//  Created by Otto Suess on 28.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

@testable import BTCUtil
import XCTest

final class Bech32Tests: XCTestCase {
    func testValidBech32() {
        let valid = [
            "A12UEL5L",
            "a12uel5l",
            "an83characterlonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1tt5tgs",
            "abcdef1qpzry9x8gf2tvdw0s3jn54khce6mua7lmqqqxw",
            "11qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqc8247j",
            "split1checkupstagehandshakeupstreamerranterredcaperred2y9e3w"
        ]
        
        for input in valid {
            let decoded = Bech32.decode(input)
            XCTAssertNotNil(decoded)
        }
    }
    
    func testInvalidBech32() {
        let invalid = [
            "\u{20}1nwldj5",
            "\u{7F}1axkwrx",
            "\u{80}1eym55h",
            "an84characterslonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1569pvx",
            "pzry9x0s0muk",
            "1pzry9x0s0muk",
            "x1b4n0q5v",
            "li1dgmt3",
            "de1lg7wt\u{FF}",
            "A1G7SGD8",
            "10a06t8",
            "1qzzfhee"
        ]
        
        for input in invalid {
            let decoded = Bech32.decode(input)
            XCTAssertNil(decoded)
        }
    }
}
