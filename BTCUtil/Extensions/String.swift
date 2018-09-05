//
//  BTCUtil
//
//  Created by Otto Suess on 27.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

public extension String {
    public var hexadecimal: Data? {
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
    
    public func sha256() -> String {
        return data(using: .utf8)?.sha256().hexString() ?? ""
    }

    func indexDistance(of character: Character) -> Int? {
        guard let index = index(of: character) else { return nil }
        return distance(from: startIndex, to: index)
    }

    func lastIndex(of string: String) -> Int? {
        guard let index = range(of: string, options: .backwards) else { return nil }
        return self.distance(from: self.startIndex, to: index.lowerBound)
    }
}
