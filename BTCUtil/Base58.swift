//
//  BTCUtil
//
//  Created by Otto Suess on 27.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BigInt
import Foundation

extension Data {
    public init?(base58Encoded base64String: String) {
        var answer = BigUInt(0)
        // swiftlint:disable:next identifier_name
        var j = BigUInt(1)
        
        for character in base64String.reversed() {
            guard let tmp = Base58.alphabet.indexDistance(of: character) else { return nil }
            answer += (BigUInt(tmp) * j)
            j *= 58
        }
        
        let leadingZeros = base64String.prefix(while: { $0 == "1" }).count
        let prefix = Data([UInt8](repeating: 0, count: leadingZeros))
        
        self = prefix + answer.serialize()
    }
    
    func base58EncodedString() -> String {
        var data = BigUInt(self)
        var result = ""
        
        while data > 0 {
            let mod = data % 58
            data /= 58
            
            let index = Base58.alphabet.index(Base58.alphabet.startIndex, offsetBy: Int(mod))
            result += String(Base58.alphabet[index])
        }
        
        for byte in self {
            if byte != 0 {
                break
            }
            result += "1"
        }
        
        return String(result.reversed())
    }
}

enum Base58 {
    fileprivate static let alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    
    // checksum
    
    private static func checksum(_ input: Data) -> Data {
        let hashed = input.sha256().sha256()
        return hashed[hashed.startIndex..<hashed.startIndex + 4]
    }
    
    static func checkDecode(_ input: String) -> (version: Int, payload: Data)? {
        guard
            let decoded = Data(base58Encoded: input),
            decoded.count >= 5
            else { return nil }
        
        let checksum = decoded[decoded.endIndex - 4..<decoded.endIndex]
        let testData = decoded[decoded.startIndex..<decoded.endIndex - 4]
        
        if !checksum.elementsEqual(Base58.checksum(Data(testData))) {
            return nil
        }

        return (version: Int(decoded[0]), payload: Data(testData.suffix(from: 1)))
    }
    
    static func checkEncode(_ input: Data, version: Int) -> String {
        var input = input
        input.insert(UInt8(version), at: 0)
        input.append(self.checksum(input))
        return input.base58EncodedString()
    }
}
