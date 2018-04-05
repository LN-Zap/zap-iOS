//
//  BTCUtilTests
//
//  Created by Otto Suess on 28.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

@testable import BTCUtil
import XCTest

class AddressTests: XCTestCase {
    func testAddressTypes() {
        let tests: [(String, BitcoinAddress.AddressType)] = [
            ("17VZNX1SN5NtKa8UQFxwQbFeFc3iqRYhem", .pubkeyHash),
            ("3EktnHQD7RiAE6uzMj2ZifT9YgRrkSgzQX", .scriptHash),
            ("5Hwgr3u458GLafKBgxtssHSPqJnYoGrSzgQsPwLFhLNYskDPyyA", .privateKey),
            ("mipcBbFg9gMiCh81Kj8tqqdgoZub1ZJRfn", .testnetPubkeyHash),
            ("2MzQwSSnBHWHqSAqtTVQ6v47XtaisrJa1Vc", .testnetScriptHash),
            ("92Pg46rUhgTT7romnV7iGW6W1gbGdeezqdbJCzShkCsYNzyyNcc", .testnetPrivateKey),
            ("1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i", .pubkeyHash),
            ("1111111111111111111114oLvT2", .pubkeyHash),
            ("17NdbrSGoUotzeGCcMMCqnFkEvLymoou9j", .pubkeyHash),
            ("1Q1pE5vPGEEMqRcVRMbtBK842Y6Pzo6nK9", .pubkeyHash)
        ]
        
        for (input, type) in tests {
            let address = BitcoinAddress(string: input)
            XCTAssertEqual(address?.type, type)
        }
    }
    
    func testInvalidAddresses() {
        let invalid = [
            "1badbadbadbadbadbadbadbadbadbadbad",
            "1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62X",
            "1ANNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i",
            "1A Na15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i"
        ]
        
        for input in invalid {
            XCTAssertNil(BitcoinAddress(string: input))
        }
    }
}
