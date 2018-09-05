//
//  BTCUtilTests
//
//  Created by Otto Suess on 05.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

@testable import BTCUtil
import XCTest

class Bech32AddressTests: XCTestCase {
    private func segwitScriptPubKey(version: Int, program: Data) -> Data {
        return [version > 0 ? UInt8(version) + 0x50 : 0, UInt8(program.count)] + program
    }
    
    // swiftlint:disable force_unwrapping
    func testEncode() {
        let addresses: [(address: String, decoded: Data)] = [
            (address: "BC1QW508D6QEJXTDG4Y5R3ZARVARY0C5XW7KV8F3T4",
             decoded: "0014751e76e8199196d454941c45d1b3a323f1433bd6".hexadecimal!),
            (address: "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7",
             decoded: "00201863143c14c5166804bd19203356da136c985678cd4d27a1b8c6329604903262".hexadecimal!),
            (address: "bc1pw508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7k7grplx",
             decoded: "5128751e76e8199196d454941c45d1b3a323f1433bd6751e76e8199196d454941c45d1b3a323f1433bd6".hexadecimal!),
            (address: "BC1SW50QA3JX3S",
             decoded: "6002751e".hexadecimal!),
            (address: "bc1zw508d6qejxtdg4y5r3zarvaryvg6kdaj",
             decoded: "5210751e76e8199196d454941c45d1b3a323".hexadecimal!),
            (address: "tb1qqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesrxh6hy",
             decoded: "0020000000c4a5cad46221b2a187905e5266362b99d5e91c6ce24d165dab93e86433".hexadecimal!)
        ]
        
        for (address, testScript) in addresses {
            let bech32Address = Bech32Address(string: address)!
            let (version, program) = bech32Address.decode()!
            let output = segwitScriptPubKey(version: version, program: program)
            
            XCTAssertEqual(output, testScript)
            
            let encoded = Bech32Address(network: bech32Address.network, witnessVersion: version, witnessProgram: program)
            
            XCTAssertEqual(encoded?.string, address.lowercased())
        }
    
    }
    
    func testValidSegwitAddresses() {
        let valid: [String] = [
            "BC1QW508D6QEJXTDG4Y5R3ZARVARY0C5XW7KV8F3T4",
            "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7",
            "bc1pw508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7k7grplx",
            "BC1SW50QA3JX3S",
            "bc1zw508d6qejxtdg4y5r3zarvaryvg6kdaj",
            "tb1qqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesrxh6hy"
        ]
        
        for input in valid {
            XCTAssertNotNil(Bech32Address(string: input), input)
        }
    }
    
    func testInvalidSegwitAddresses() {
        let invalid = [
            // "tc1qw508d6qejxtdg4y5r3zarvary0c5xw7kg3g4ty",
            "bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t5",
            "BC13W508D6QEJXTDG4Y5R3ZARVARY0C5XW7KN40WF2",
            "bc1rw5uspcuh",
            "bc10w508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7kw5rljs90",
            "BC1QR508D6QEJXTDG4Y5R3ZARVARYV98GJ9P",
            "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sL5k7",
            "bc1zw508d6qejxtdg4y5r3zarvaryvqyzf3du",
            "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3pjxtptv",
            "bc1gmk9yu"
        ]
        
        for input in invalid {
            XCTAssertNil(Bech32Address(string: input))
        }
    }
}
