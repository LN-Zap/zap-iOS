//
//  SwiftLnd
//
//  Created by Otto Suess on 15.11.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

extension Data {
    public init?(hexadecimalString: String) {
        guard let regex = try? NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive) else { return nil }
        
        var data = Data(capacity: hexadecimalString.count / 2)
        // swiftlint:disable:next legacy_constructor
        regex.enumerateMatches(in: hexadecimalString, range: NSMakeRange(0, hexadecimalString.utf16.count)) { match, _, _ in
            guard let match = match else { return }
            let byteString = (hexadecimalString as NSString).substring(with: match.range)
            if var num = UInt8(byteString, radix: 16) {
                data.append(&num, count: 1)
            }
        }
        
        if data.isEmpty {
            return nil
        }
        
        self = data
    }
}
