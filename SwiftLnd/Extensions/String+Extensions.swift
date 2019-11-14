//
//  SwiftLnd
//
//  Created by Otto Suess on 15.11.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

extension String {
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
    
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}
