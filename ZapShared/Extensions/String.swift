//
//  Zap
//
//  Created by Otto Suess on 23.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

extension String {
    func hexadecimal() -> Data? {
        guard let regex = try? NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
            else { return nil }
        var data = Data(capacity: count / 2)
        // swiftlint:disable:next legacy_constructor
        regex.enumerateMatches(in: self, range: NSMakeRange(0, utf16.count)) { match, _, _ in
            guard let match = match else { return }
            let byteString = (self as NSString).substring(with: match.range)
            if var num = UInt8(byteString, radix: 16) {
                data.append(&num, count: 1)
            }
        }
        if data.isEmpty {
            return nil
        }
        return data
    }
    
    private func hexBytes() -> [String] {
        var result = [String]()
        var currentIndex = startIndex
        while currentIndex != endIndex {
            let end = index(currentIndex, offsetBy: 2)
            result.append(String(self[currentIndex..<end]))
            currentIndex = end
        }
        return result
    }
    
    func hexEndianSwap() -> String {
        return hexBytes().reversed().joined()
    }
    
    func starts(with prefixes: [String]) -> Bool {
        for prefix in prefixes where starts(with: prefix) {
            return true
        }
        return false
    }
}
