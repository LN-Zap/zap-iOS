//
//  BTCUtil
//
//  Created by Otto Suess on 28.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

// BIP: https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki

enum Bech32 {
    private static let alphabet = "qpzry9x8gf2tvdw0s3jn54khce6mua7l"
    private static let generator = [0x3b6a57b2, 0x26508e6d, 0x1ea119fa, 0x3d4233dd, 0x2a1462b3]
    
    private static func expandHumanReadablePart(_ humanReadablePart: String) -> [UInt8] {
        guard let stringBytes = humanReadablePart.data(using: .utf8) else { return [] }
        var data = [UInt8]()
        
        for character in stringBytes {
            data.append(UInt8(UInt32(character) >> 5))
        }
        data.append(0)
        for character in stringBytes {
            data.append(UInt8(UInt32(character) & 31))
        }
        return data
    }
    
    private static func polymod(values: [UInt8]) -> Int {
        var chk = 1
        // swiftlint:disable:next identifier_name
        for p in values {
            let top = chk >> 25
            chk = (chk & 0x1ffffff) << 5 ^ Int(p)
            // swiftlint:disable:next identifier_name
            for (i, g) in Bech32.generator.enumerated() where ((top >> i) & 1) != 0 {
                chk ^= g
            }
        }
        return chk
    }

    private static func verifyChecksum(humanReadablePart: String, data: Data) -> Bool {
        return polymod(values: expandHumanReadablePart(humanReadablePart) + data) == 1
    }
    
    private static func hasValidCharacters(_ bechString: String) -> Bool {
        guard let stringBytes = bechString.data(using: .utf8) else { return false }

        var hasLower = false
        var hasUpper = false

        for character in stringBytes {
            let code = UInt32(character)
            if code < 33 || code > 126 {
                return false
            } else if code >= 97 && code <= 122 {
                hasLower = true
            } else if code >= 65 && code <= 90 {
                hasUpper = true
            }
        }
        
        return !(hasLower && hasUpper)
    }
    
    static func decode(_ bechString: String, limit: Bool = true) -> (humanReadablePart: String, data: Data)? {
        guard hasValidCharacters(bechString) else { return nil }
        
        let bechString = bechString.lowercased()
        guard let pos = bechString.lastIndex(of: "1") else { return nil }
        
        if pos < 1 || pos + 7 > bechString.count || (limit && bechString.count > 90) {
            return nil
        }
        
        let humanReadablePart = String(bechString.prefix(pos))
        let dataPart = bechString.suffix(bechString.count - humanReadablePart.count - 1)
    
        var data = Data()
        for character in dataPart {
            guard let distance = Bech32.alphabet.indexDistance(of: character) else { return nil }
            data.append(UInt8(distance))
        }
        
        if !verifyChecksum(humanReadablePart: humanReadablePart, data: data) {
            return nil
        }

        return (humanReadablePart, Data(data[..<(data.count - 6)]))
    }
}

enum SegwitAddress {
    static func convertBits(data: Data, fromBits: Int, toBits: Int, pad: Bool) -> Data? {
        var acc: Int = 0
        var bits: Int = 0
        var ret = Data()
        let maxv: Int = (1 << toBits) - 1

        for value in data {
            if value < 0 || (value >> fromBits) != 0 {
                return nil
            }

            acc = (acc << fromBits) | Int(value)
            bits += fromBits

            while bits >= toBits {
                bits -= toBits
                ret.append(UInt8((acc >> bits) & maxv))
            }
        }

        if pad {
            if bits > 0 {
                ret.append(UInt8((acc << (toBits - bits)) & maxv))
            }
        } else if bits >= fromBits || ((acc << (toBits - bits)) & maxv) != 0 {
            return nil
        }

        return ret
    }
    
    static func decode(hrp: String, addr: String) -> (version: Int, program: Data)? {
        guard let dec = Bech32.decode(addr) else { return nil }
        
        if dec.humanReadablePart != hrp || dec.data.count < 1 || dec.data[0] > 16 {
            return nil
        }
        guard let res = convertBits(data: dec.data.advanced(by: 1), fromBits: 5, toBits: 8, pad: false) else {
            return nil
        }
        if res.count < 2 || res.count > 40 {
            return nil
        }
        if dec.data[0] == 0 && res.count != 20 && res.count != 32 {
            return nil
        }
        return (version: Int(dec.data[0]), program: res)
    }
}
