//
//  SwiftBTC
//
//  Created by Otto Suess on 27.02.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import CommonCrypto
import Foundation

public extension Data {
    var sha256: Data {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        
        let bytes = withUnsafeBytes { (bytes: UnsafePointer<UInt8>) in
            Array(UnsafeBufferPointer(start: bytes, count: count / MemoryLayout<UInt8>.stride))
        }
        
        CC_SHA256(bytes, UInt32(count), &hash)
        return Data(hash)
    }
    
    public var hexadecimalString: String {
        return reduce("") { $0 + String(format: "%02x", UInt8($1)) }
    }
    
    // ConvertBits converts a byte slice where each byte is encoding fromBits bits,
    // to a byte slice where each byte is encoding toBits bits.
    public func convertBits(fromBits: Int, toBits: Int, pad: Bool) -> Data? {
        var acc: Int = 0
        var bits: Int = 0
        var result = Data()
        let maxv: Int = (1 << toBits) - 1
        
        for value in self {
            if value < 0 || (value >> fromBits) != 0 {
                return nil
            }
            
            acc = (acc << fromBits) | Int(value)
            bits += fromBits
            
            while bits >= toBits {
                bits -= toBits
                result.append(UInt8((acc >> bits) & maxv))
            }
        }
        
        if pad {
            if bits > 0 {
                result.append(UInt8((acc << (toBits - bits)) & maxv))
            }
        } else if bits >= fromBits || ((acc << (toBits - bits)) & maxv) != 0 {
            return nil
        }
        
        return result
    }
}
