//
//  Zap
//
//  Created by Otto Suess on 28.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit

final class TransactionListViewModel: NSObject {
    let sections: MutableObservable2DArray<String, TransactionViewModel>
    
    init(viewModel: ViewModel) {
        sections = MutableObservable2DArray()
        super.init()
        
        combineLatest(viewModel.onChainTransactions, viewModel.payments) {
            return $0 as [Transaction] + $1 as [Transaction]
        }
        .observeNext { [weak self] transactions in
            guard let result = self?.bondSections(transactions: transactions) else { return }
            let array = Observable2DArray(result)
            self?.sections.replace(with: array, performDiff: true)
        }
        .dispose(in: reactive.bag)
    }
    
    private func dateWithoutTime(from date: Date) -> Date {
        let components = Calendar.current.dateComponents([.day, .month, .year], from: date)
        return Calendar.current.date(from: components) ?? date
    }
    
    private func sortedSections(transactions: [Transaction]) -> [(Date, [Transaction])] {
        let grouped = transactions.grouped { transaction -> Date in
            return self.dateWithoutTime(from: transaction.date)
        }
        
        return Array(zip(grouped.keys, grouped.values))
            .sorted { $0.0 > $1.0 }
    }
    
    private func bondSections(transactions: [Transaction]) -> [Observable2DArraySection<String, TransactionViewModel>] {
        let sortedSections = self.sortedSections(transactions: transactions)
        
        return sortedSections.compactMap {
            let sortedItems = $0.1.sorted { $0.date > $1.date }
            
            guard let date = $0.1.first?.date else { return nil }
            
            let dateString = DateFormatter.localizedString(from: date, dateStyle: .long, timeStyle: .none)
            
            return Observable2DArraySection<String, TransactionViewModel>(
                metadata: dateString,
                items: sortedItems.map { TransactionViewModel(transaction: $0) }
            )
        }
    }
}
