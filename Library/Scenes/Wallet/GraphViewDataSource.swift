//
//  Library
//
//  Created by Otto Suess on 06.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation
import Lightning
import ScrollableGraphView

final class GraphViewDataSource: ScrollableGraphViewDataSource {
    let plotData: [(date: Date, amount: Satoshi)]
    let currency: Currency
    
    init(currentValue: Satoshi, plottableEvents: [PlottableEvent], currency: Currency) {
        self.currency = currency
        let currentDate = Date()
        
        var result = [(date: Date, amount: Satoshi)]()
        
        let transactionsByDay = GraphViewDataSource.amountDeltaByDay(plottableEvents: plottableEvents, currentDate: currentDate)
        
        var sum: Satoshi = currentValue
        if let longestDayDistance = transactionsByDay.keys.min() {
            result = stride(from: 0, to: (longestDayDistance - 1), by: -1)
                .map { day in
                    let date = currentDate.add(day: day - 1)
                    let delta = transactionsByDay[day] ?? 0
                    sum -= delta
                    if sum < 0 {
                        sum = 0
                    }
                    return (date, sum)
                }
                .reversed()
        } else {
            result = []
        }
        
        if let first = result.first,
            first.amount != 0 {
            result.insert((date: first.date.add(day: -1), amount: 0), at: 0)
        } else if result.isEmpty && currentValue > 0 {
            result.insert((date: currentDate.add(day: -1), amount: 0), at: 0)
        }
        
        result.append((date: currentDate, amount: currentValue))
        
        plotData = result
    }
    
    private static func amountDeltaByDay(plottableEvents: [PlottableEvent], currentDate: Date) -> [Int: Satoshi] {
        var transactionsByDay = [Int: Satoshi]()
        for plottableEvent in plottableEvents {
            let dayDistance = currentDate.daysTo(end: plottableEvent.date)
            if let currentValue = transactionsByDay[dayDistance] {
                transactionsByDay[dayDistance] = currentValue + plottableEvent.amount
            } else {
                transactionsByDay[dayDistance] = plottableEvent.amount
            }
        }
        return transactionsByDay
    }
    
    // MARK: - ScrollableGraphViewDataSource
    
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        guard let value = currency.value(satoshis: plotData[pointIndex].amount) else { return 0 }
        return Double(truncating: value as NSNumber)
    }
    
    func label(atIndex pointIndex: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: plotData[pointIndex].date)
    }
    
    func numberOfPoints() -> Int {
        return plotData.count
    }
}

extension GraphViewDataSource: CustomDebugStringConvertible {
    var debugDescription: String {
        return plotData.reduce("Point count: \(plotData.count)") {
            $0 + "\n\($1.date): \($1.amount)"
        }
    }
}
