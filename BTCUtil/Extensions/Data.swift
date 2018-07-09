//
//  BTCUtil
//
//  Created by Otto Suess on 27.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import CommonCrypto
import Foundation

public extension Data {
    func sha256() -> Data {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        
        let bytes = withUnsafeBytes { (bytes: UnsafePointer<UInt8>) in
            Array(UnsafeBufferPointer(start: bytes, count: count / MemoryLayout<UInt8>.stride))
        }
        
        CC_SHA256(bytes, UInt32(count), &hash)
        return Data(hash)
    }
    
    public func hexString() -> String {
        return reduce("") { $0 + String(format: "%02x", UInt8($1)) }
    }
}
