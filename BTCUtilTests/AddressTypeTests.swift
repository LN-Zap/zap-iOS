//
//  BTCUtilTests
//
//  Created by Otto Suess on 05.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

@testable import BTCUtil
import XCTest

final class AddressTypeTests: XCTestCase {
    
    func testLightningNode() {
        let valid: [String] = [
            "039cc950286a8fa99218283d1adc2456e0d5e81be558da77dd6e85ba9a1fff5ad3@34.200.252.146",
            "039cc950286a8fa99218283d1adc2456e0d5e81be558da77dd6e85ba9a1fff5ad3@34.200.252.146",
            "02f6725f9c1c40333b67faea92fd211c183050f28df32cac3f9d69685fe9665432@104.198.32.198:",
            "02f6725f9c1c40333b67faea92fd211c183050f28df32cac3f9d69685fe9665432@104.198.32.198:9735",
            "02f6725f9c1c40333b67faea92fd211c183050f28df32cac3f9d69685fe9665432 104.198.32.198 9735",
            "02f6725f9c1c40333b67faea92fd211c183050f28df32cac3f9d69685fe9665432@104.198.32.198",
            "02f6725f9c1c40333b67faea92fd211c183050f28df32cac3f9d69685fe9665432   104.198.32.198"
        ]
        
        for uri in valid {
            XCTAssertNotNil(LightningNodeURI(string: uri))
        }
        
        let invalid: [String] = [
            "abcd123",
            "02f6725f9c1c40333b67faea92fd211c183050f28df32cac3f9d69685fe9665432"
        ]
        
        for uri in invalid {
            XCTAssertNil(LightningNodeURI(string: uri))
        }
    }
    
    func testBitcoinAddress() {
        let tests: [(String, Network)] = [
            ("17VZNX1SN5NtKa8UQFxwQbFeFc3iqRYhem", .mainnet),
            ("2N8hwP1WmJrFF5QWABn38y63uYLhnJYJYTF", .testnet),
            ("bitcoin:17VZNX1SN5NtKa8UQFxwQbFeFc3iqRYhem", .mainnet),
            ("bitcoin:2N8hwP1WmJrFF5QWABn38y63uYLhnJYJYTF", .testnet)
        ]
        
        for (input, network) in tests {
            let uri = BitcoinURI(string: input)
            XCTAssertEqual(uri?.network, network, "\(input), \(network) = \(String(describing: uri?.network))")
        }
    }
    
    func testBech32Address() {
        let tests: [(String, Network)] = [
            ("bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4", .mainnet),
            ("bc1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3qccfmv3", .mainnet),
            ("tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx", .testnet),
            ("tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7", .testnet)
        ]
        
        for (uri, network) in tests {
            let uri = BitcoinURI(string: uri)
            XCTAssertEqual(uri?.network, network)
        }
    }
    
    func testLightningInvoice() {
        let tests: [(String, Network)] = [
            ("lntb1500n1pdvtehjpp58asu5u6a3yc77r6qu4ax6agt25a8kv2yytvcfpw6us3rducmt2hqdp62fjkzepqg9e8g6trd3jn5gzfyp9kummhyptksmeq2dshgmmndp5jqjtnp5cqzysssldhps8qg2q5r8klnhpms2r80jhd4kx68m4vs2l4pdjcaw7k3l5dmgr5l9xm6aee8mlr8p27ur6aagneutg983khs8nart6l4r07zgqdk7lp7", .testnet),
            ("lnbc1500n1pdvte6dpp54u8s3dru3ffrlkgrvrqyr70r8plerhqfrupqe925gnwjmvav6aasdzh2fjkzepqg9e8g6trd3jn5gzzv4nkjmnwv4ew9qyewvsywatfv3jjqar0yrhm3rlzn2s5c6t8dp6xu6twvlhm3rccqzys22ty7g7jfnwv0pft3qp79lnkwzlljq29lp6vvzr9enygre2t9u93kthd22vks0uw3xjapq4smkjf6q06uu30ct3542cfscq0e54z7fsqw9vq22", .mainnet)
        ]
        
        for (uri, network) in tests {
            let uri = LightningURI(string: uri)
            XCTAssertEqual(uri?.network, network)
        }
    }
}
