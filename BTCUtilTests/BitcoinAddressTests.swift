//
//  BTCUtilTests
//
//  Created by Otto Suess on 28.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

@testable import BTCUtil
import XCTest

final class AddressTests: XCTestCase {
    func testAddressTypes() {
        let tests: [(String, BitcoinAddress.AddressType, Network)] = [
            ("17VZNX1SN5NtKa8UQFxwQbFeFc3iqRYhem", .pubkeyHash, .mainnet),
            ("3EktnHQD7RiAE6uzMj2ZifT9YgRrkSgzQX", .scriptHash, .mainnet),
            ("5Hwgr3u458GLafKBgxtssHSPqJnYoGrSzgQsPwLFhLNYskDPyyA", .privateKey, .mainnet),
            ("mipcBbFg9gMiCh81Kj8tqqdgoZub1ZJRfn", .pubkeyHash, .testnet),
            ("2MzQwSSnBHWHqSAqtTVQ6v47XtaisrJa1Vc", .scriptHash, .testnet),
            ("92Pg46rUhgTT7romnV7iGW6W1gbGdeezqdbJCzShkCsYNzyyNcc", .privateKey, .testnet),
            ("1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i", .pubkeyHash, .mainnet),
            ("1111111111111111111114oLvT2", .pubkeyHash, .mainnet),
            ("17NdbrSGoUotzeGCcMMCqnFkEvLymoou9j", .pubkeyHash, .mainnet),
            ("1Q1pE5vPGEEMqRcVRMbtBK842Y6Pzo6nK9", .pubkeyHash, .mainnet)
        ]
        
        for (input, type, network) in tests {
            let address = BitcoinAddress(string: input)
            XCTAssertEqual(address?.type, type)
            XCTAssertEqual(address?.network, network)
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
