//
//  BTCUtilTests
//
//  Created by Otto Suess on 05.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

@testable import BTCUtil
import XCTest

class AddressTypeTests: XCTestCase {
    
    func testLightningNode() {
        XCTAssertTrue(AddressType.lightningNode.isValidAddress("039cc950286a8fa99218283d1adc2456e0d5e81be558da77dd6e85ba9a1fff5ad3@34.200.252.146", network: .mainnet))
        XCTAssertTrue(AddressType.lightningNode.isValidAddress("039cc950286a8fa99218283d1adc2456e0d5e81be558da77dd6e85ba9a1fff5ad3@34.200.252.146", network: .testnet))
        XCTAssertFalse(AddressType.lightningNode.isValidAddress("abcd123", network: .testnet))
        XCTAssertFalse(AddressType.lightningNode.isValidAddress("02f6725f9c1c40333b67faea92fd211c183050f28df32cac3f9d69685fe9665432", network: .testnet))
        XCTAssertTrue(AddressType.lightningNode.isValidAddress("02f6725f9c1c40333b67faea92fd211c183050f28df32cac3f9d69685fe9665432@104.198.32.198:", network: .testnet))
        XCTAssertTrue(AddressType.lightningNode.isValidAddress("02f6725f9c1c40333b67faea92fd211c183050f28df32cac3f9d69685fe9665432@104.198.32.198:9735", network: .testnet))
        XCTAssertTrue(AddressType.lightningNode.isValidAddress("02f6725f9c1c40333b67faea92fd211c183050f28df32cac3f9d69685fe9665432 104.198.32.198 9735", network: .testnet))
        XCTAssertTrue(AddressType.lightningNode.isValidAddress("02f6725f9c1c40333b67faea92fd211c183050f28df32cac3f9d69685fe9665432@104.198.32.198", network: .testnet))
        XCTAssertTrue(AddressType.lightningNode.isValidAddress("02f6725f9c1c40333b67faea92fd211c183050f28df32cac3f9d69685fe9665432   104.198.32.198", network: .testnet))
    }
    
    func testBitcoinAddress() {
        XCTAssertTrue(AddressType.bitcoinAddress.isValidAddress("17VZNX1SN5NtKa8UQFxwQbFeFc3iqRYhem", network: .mainnet))
        XCTAssertFalse(AddressType.bitcoinAddress.isValidAddress("17VZNX1SN5NtKa8UQFxwQbFeFc3iqRYhem", network: .testnet))
        XCTAssertTrue(AddressType.bitcoinAddress.isValidAddress("2N8hwP1WmJrFF5QWABn38y63uYLhnJYJYTF", network: .testnet))
        XCTAssertFalse(AddressType.bitcoinAddress.isValidAddress("2N8hwP1WmJrFF5QWABn38y63uYLhnJYJYTF", network: .mainnet))
    }
    
    func testLightningInvoice() {
        XCTAssertTrue(AddressType.lightningInvoice.isValidAddress("lntb1500n1pdvtehjpp58asu5u6a3yc77r6qu4ax6agt25a8kv2yytvcfpw6us3rducmt2hqdp62fjkzepqg9e8g6trd3jn5gzfyp9kummhyptksmeq2dshgmmndp5jqjtnp5cqzysssldhps8qg2q5r8klnhpms2r80jhd4kx68m4vs2l4pdjcaw7k3l5dmgr5l9xm6aee8mlr8p27ur6aagneutg983khs8nart6l4r07zgqdk7lp7", network: .testnet))
        XCTAssertFalse(AddressType.lightningInvoice.isValidAddress("lntb1500n1pdvtehjpp58asu5u6a3yc77r6qu4ax6agt25a8kv2yytvcfpw6us3rducmt2hqdp62fjkzepqg9e8g6trd3jn5gzfyp9kummhyptksmeq2dshgmmndp5jqjtnp5cqzysssldhps8qg2q5r8klnhpms2r80jhd4kx68m4vs2l4pdjcaw7k3l5dmgr5l9xm6aee8mlr8p27ur6aagneutg983khs8nart6l4r07zgqdk7lp7", network: .mainnet))
        XCTAssertTrue(AddressType.lightningInvoice.isValidAddress("lnbc1500n1pdvte6dpp54u8s3dru3ffrlkgrvrqyr70r8plerhqfrupqe925gnwjmvav6aasdzh2fjkzepqg9e8g6trd3jn5gzzv4nkjmnwv4ew9qyewvsywatfv3jjqar0yrhm3rlzn2s5c6t8dp6xu6twvlhm3rccqzys22ty7g7jfnwv0pft3qp79lnkwzlljq29lp6vvzr9enygre2t9u93kthd22vks0uw3xjapq4smkjf6q06uu30ct3542cfscq0e54z7fsqw9vq22", network: .mainnet))
        XCTAssertFalse(AddressType.lightningInvoice.isValidAddress("lnbc1500n1pdvte6dpp54u8s3dru3ffrlkgrvrqyr70r8plerhqfrupqe925gnwjmvav6aasdzh2fjkzepqg9e8g6trd3jn5gzzv4nkjmnwv4ew9qyewvsywatfv3jjqar0yrhm3rlzn2s5c6t8dp6xu6twvlhm3rccqzys22ty7g7jfnwv0pft3qp79lnkwzlljq29lp6vvzr9enygre2t9u93kthd22vks0uw3xjapq4smkjf6q06uu30ct3542cfscq0e54z7fsqw9vq22", network: .testnet))
    }
}
