//
//  Library
//
//  Created by Otto Suess on 13.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation



public struct DateWrappedChannelEvent: Equatable, DateProvidingEvent {
    public let date: Date
    public let channelEvent: ChannelEvent
}

public final class DateEstimator {
    private let transactions: [(date: Date, blockHeight: Int)]
    
    public convenience init() {
        let transactions = (try? TransactionEvent.events()) ?? []
        self.init(transactions: transactions)
    }
    
    public init(transactions: [TransactionEvent]) {
        self.transactions = transactions
            .compactMap {
                guard let blockHeight = $0.blockHeight else { return nil }
                return ($0.date, blockHeight)
            }
            .sorted(by: { $0.1 < $1.1 })
    }
    
    public func wrapChannelEvent(_ channelEvent: ChannelEvent) -> DateWrappedChannelEvent {
        let date = estimatedDate(forBlockHeight: channelEvent.blockHeight) ?? Date(timeIntervalSince1970: 0)
        return DateWrappedChannelEvent(date: date, channelEvent: channelEvent)
    }
    
    func estimatedDate(forBlockHeight blockHeight: Int) -> Date? {
        let index = transactions.binarySearch { blockHeight >= $0.blockHeight }
        
        if index == 0 {
            return nil
        } else if transactions[index - 1].blockHeight == blockHeight {
            return transactions[index - 1].date
        } else if index == transactions.count {
            return nil
        } else {
            let lower = transactions[index - 1]
            let upper = transactions[index]
            let timeDelta = upper.date.timeIntervalSince(lower.date)
            let newTimeDelta = timeDelta * Double(blockHeight - lower.blockHeight) / Double(upper.blockHeight - lower.blockHeight)
            return lower.date.addingTimeInterval(newTimeDelta)
        }
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
