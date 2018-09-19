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
import SwiftLnd

protocol Transaction: DateProvidingEvent {
    var amount: Satoshi { get }
}

final class GraphViewDataSource: ScrollableGraphViewDataSource {
    let plotData: [(date: Date, amount: Satoshi)]
    
    init(transactions: [Transaction]) {
        var transactionsByDay = [Int: [Transaction]]()
        let currentDate = Date()
        
        for transaction in transactions {
            let dayDistance = currentDate.daysTo(end: transaction.date)
            if transactionsByDay[dayDistance] == nil {
                transactionsByDay[dayDistance] = [transaction]
            } else {
                transactionsByDay[dayDistance]?.append(transaction)
            }
        }
        
        var sum: Satoshi = 0
        if let longestDayDistance = transactionsByDay.keys.min() {
            plotData = ((longestDayDistance - 1)...0).map { day in
                let date = currentDate.add(day: day)
                let delta = GraphViewDataSource.transactionSum(transactionsByDay[day] ?? [])
                sum += delta
                
                return (date, sum)
            }
        } else {
            plotData = []
        }
    }
    
    private static func transactionSum(_ transactions: [Transaction]) -> Satoshi {
        return transactions.reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - ScrollableGraphViewDataSource
    
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        let currency = Settings.shared.cryptoCurrency.value
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
