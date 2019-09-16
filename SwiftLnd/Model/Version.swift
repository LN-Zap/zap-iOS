//
//  SwiftLnd
//
//  Created by 0 on 02.04.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

private func paddedZip(_ left: [Int], _ right: [Int]) -> [(Int, Int)] {
    return (0..<max(left.count, right.count))
        .map { (left[safe: $0] ?? 0, right[safe: $0] ?? 0) }
}

public struct Version {
    public struct Number: CustomStringConvertible, Comparable, Equatable {
        public static func == (lhs: Number, rhs: Number) -> Bool {
            for (lhs, rhs) in paddedZip(lhs.components, rhs.components) where lhs != rhs {
                return false
            }
            return true
        }

        public static func < (lhs: Number, rhs: Number) -> Bool {
            for (lhs, rhs) in paddedZip(lhs.components, rhs.components) where lhs != rhs {
                return lhs < rhs
            }
            return false
        }

        let components: [Int]

        public var description: String {
            return components
                .map { String($0) }
                .joined(separator: ".")
        }

        public init?(string: String) {
            guard let range = string.range(of: #"[\d\.]+"#, options: .regularExpression) else { return nil }
            components = string[range]
                .split(separator: ".")
                .compactMap { Int($0) }
            guard !components.isEmpty else { return nil }
        }
    }

    public let number: Number
    public let commit: String?

    init?(string: String) {
        guard let number = Number(string: string) else { return nil }
        self.number = number
        self.commit = string.components(separatedBy: CharacterSet(charactersIn: "=-")).last
    }
}
