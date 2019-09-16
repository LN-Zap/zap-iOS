//
//  Library
//
//  Created by Otto Suess on 13.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftLnd

public final class DateEstimator {
    private let transactions: [(date: Date, blockHeight: Int)]

    public init(transactions: [Transaction]) {
        self.transactions = transactions
            .compactMap {
                guard let blockHeight = $0.blockHeight else { return nil }
                return ($0.date, blockHeight)
            }
            .sorted(by: { $0.1 < $1.1 })
    }

    func estimatedDate(forBlockHeight blockHeight: Int) -> Date? {
        guard !transactions.isEmpty else { return nil }

        let index = transactions.binarySearch { blockHeight >= $0.blockHeight }

        if index == 0 {
            return dateFor(reference: transactions[0], blockHeight: blockHeight)
        } else if transactions[index - 1].blockHeight == blockHeight {
            return transactions[index - 1].date
        } else if index == transactions.count {
            return dateFor(reference: transactions[transactions.count - 1], blockHeight: blockHeight)
        } else {
            let lower = transactions[index - 1]
            let upper = transactions[index]
            let timeDelta = upper.date.timeIntervalSince(lower.date)
            let newTimeDelta = timeDelta * Double(blockHeight - lower.blockHeight) / Double(upper.blockHeight - lower.blockHeight)
            return lower.date.addingTimeInterval(newTimeDelta)
        }
    }

    private func dateFor(reference: (date: Date, blockHeight: Int), blockHeight: Int) -> Date {
        let blockOffset = reference.blockHeight - blockHeight
        return reference.date - TimeInterval(10 * 60 * blockOffset)

    }
}

private extension Collection {
    func binarySearch(predicate: (Iterator.Element) -> Bool) -> Index {
        var low = startIndex
        var high = endIndex
        while low != high {
            let mid = index(low, offsetBy: distance(from: low, to: high) / 2)
            if predicate(self[mid]) {
                low = index(after: mid)
            } else {
                high = mid
            }
        }
        return low
    }
}
