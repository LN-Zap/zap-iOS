//
//  BTCUtil
//
//  Created by Otto Suess on 27.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BigInt
import Foundation

enum Base58 {
    private static let alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    
    static func decode(_ input: String) -> Data? {
        let bigRadix = BigUInt(58)

        var answer = BigUInt(0)
        // swiftlint:disable:next identifier_name
        var j = BigUInt(1)

        for character in input.reversed() {
            guard let tmp = Base58.alphabet.indexDistance(of: character) else { return nil }
            answer += (BigUInt(tmp) * j)
            j *= bigRadix
        }
    
        let leadingZeros = input.prefix(while: { $0 == "1" }).count
        let prefix = Data([UInt8](repeating: 0, count: leadingZeros))

        return prefix + answer.serialize()
    }

    private static func checksum(_ input: Data) -> Data {
        let hashed = input.sha256().sha256()
        return hashed[hashed.startIndex..<hashed.startIndex + 4]
    }
    
    static func checkDecode(_ input: String) -> (version: Int, payload: Data)? {
        guard
            let decoded = Base58.decode(input),
            decoded.count >= 5
            else { return nil }
        
        let checksum = decoded[decoded.endIndex - 4..<decoded.endIndex]
        let testData = decoded[decoded.startIndex..<decoded.endIndex - 4]
        
        if !checksum.elementsEqual(Base58.checksum(Data(testData))) {
            return nil
        }

        return (version: Int(decoded[0]), payload: Data(testData.suffix(from: 1)))
    }
}
