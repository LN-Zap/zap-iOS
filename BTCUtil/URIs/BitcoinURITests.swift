//
//  BTCUtilTests
//
//  Created by Otto Suess on 10.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

@testable import BTCUtil
import XCTest

final class BitcoinURITests: XCTestCase {
    // swiftlint:disable:next large_tuple
    let tests: [(String, String, Satoshi?, String?, String?)] = [
        ("bitcoin:mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p", "mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p", nil, nil, nil),
        ("bitcoin:mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p?message=Luke-Jr", "mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p", nil, "Luke-Jr", nil),
        ("bitcoin:mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p?amount=20.3&message=Luke-Jr", "mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p", 2030000000, "Luke-Jr", nil),
        ("bitcoin:mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p?amount=50&message=Donation%20for%20project%20xyz", "mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p", 5000000000, "Donation for project xyz", nil),
        ("bitcoin:mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p?lightning=lntb1500n1pdhdgqjpp5g3rx8txesv7z5pd6pfyp4zqql9lq4cfqvm4d6eve8mwte0d7uydsdpa2fjkzep6yp8hq6twd9hkugz9v35hgmmjd9skcw3qgde8jur5dus9wmmvwejhxcqzysqwez4c6m2070ltq2mfz3ffc5chvwwq6q7tec2pmauths5wpng8ny24aq8gqtuj4w9jmprqt4y50ux27222nkmqfmlkulfr2h6swuqrgpj3ekm4", "mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p", nil, nil, "lntb1500n1pdhdgqjpp5g3rx8txesv7z5pd6pfyp4zqql9lq4cfqvm4d6eve8mwte0d7uydsdpa2fjkzep6yp8hq6twd9hkugz9v35hgmmjd9skcw3qgde8jur5dus9wmmvwejhxcqzysqwez4c6m2070ltq2mfz3ffc5chvwwq6q7tec2pmauths5wpng8ny24aq8gqtuj4w9jmprqt4y50ux27222nkmqfmlkulfr2h6swuqrgpj3ekm4")
    ]

    func testBitcoinURI() {
        for (uriString, address, amount, memo, lightningFallback) in tests {
            // swiftlint:disable:next force_unwrapping
            let address = BitcoinAddress(string: address)!
            XCTAssertEqual(BitcoinURI(address: address, amount: amount, memo: memo, lightningFallback: lightningFallback)?.uriString, uriString)
        }
    }
    
    func testInitWithString() {
        for (uriString, address, amount, memo, lightningFallback) in tests {
            let uri = BitcoinURI(string: uriString)
            XCTAssertEqual(uri?.address, address)
            XCTAssertEqual(uri?.amount, amount)
            XCTAssertEqual(uri?.memo, memo)
            XCTAssertEqual(uri?.lightningFallback, lightningFallback)
        }
    }
    
    func testAddressOrURI() {
        let tests: [(String, String, Satoshi?, String?, String?)] = [
            ("bitcoin:mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p", "mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p", nil, nil, nil),
            ("bitcoin:mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p?message=Luke-Jr", "mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p", nil, "Luke-Jr", nil),
            ("bitcoin:mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p?amount=20.3&message=Luke-Jr", "mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p", 2030000000, "Luke-Jr", nil),
            ("bitcoin:mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p?amount=50&message=Donation%20for%20project%20xyz", "mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p", 5000000000, "Donation for project xyz", nil),
            ("bitcoin:mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p?amount=50&message=Donation%20for%20project%20xyz", "mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p", 5000000000, "Donation for project xyz", nil),
            ("bitcoin:mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p?amount=50&message=Donation%20for%20project%20xyz&lightning=lntb1500n1pdhdgqjpp5g3rx8txesv7z5pd6pfyp4zqql9lq4cfqvm4d6eve8mwte0d7uydsdpa2fjkzep6yp8hq6twd9hkugz9v35hgmmjd9skcw3qgde8jur5dus9wmmvwejhxcqzysqwez4c6m2070ltq2mfz3ffc5chvwwq6q7tec2pmauths5wpng8ny24aq8gqtuj4w9jmprqt4y50ux27222nkmqfmlkulfr2h6swuqrgpj3ekm4", "mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p", 5000000000, "Donation for project xyz", "lntb1500n1pdhdgqjpp5g3rx8txesv7z5pd6pfyp4zqql9lq4cfqvm4d6eve8mwte0d7uydsdpa2fjkzep6yp8hq6twd9hkugz9v35hgmmjd9skcw3qgde8jur5dus9wmmvwejhxcqzysqwez4c6m2070ltq2mfz3ffc5chvwwq6q7tec2pmauths5wpng8ny24aq8gqtuj4w9jmprqt4y50ux27222nkmqfmlkulfr2h6swuqrgpj3ekm4")

        ]
        
        for (uriString, address, amount, memo, lightningFallback) in tests {
            // swiftlint:disable:next force_unwrapping
            let address = BitcoinAddress(string: address)!
            XCTAssertEqual(BitcoinURI(address: address, amount: amount, memo: memo, lightningFallback: lightningFallback)?.uriString, uriString)
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
    
    func testWhiteSpace() {
        let tests: [String] = [
            "  17VZNX1SN5NtKa8UQFxwQbFeFc3iqRYhem",
            "2N8hwP1WmJrFF5QWABn38y63uYLhnJYJYTF  ",
            "\n\tbc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4\n\n",
            "bc1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3qccfmv3\n",
            " bitcoin:mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p "
        ]
        
        for input in tests {
            let uri = BitcoinURI(string: input)
            XCTAssertNotNil(uri)
        }
    }
}
