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
    private let transactionService: TransactionService
    private let aliasStore: ChannelAliasStore
    let transactionAnnotationStore = TransactionAnnotationStore()
    
    let sections: MutableObservable2DArray<String, TransactionViewModel>
    
    init(transactionService: TransactionService, aliasStore: ChannelAliasStore) {
        self.transactionService = transactionService
        self.aliasStore = aliasStore
        sections = MutableObservable2DArray()
        
        super.init()
        
        transactionService.transactions
            .observeNext(with: updateSections)
            .dispose(in: reactive.bag)
    }
    
    func refresh() {
        transactionService.update()
    }
    
    func hideTransaction(_ transactionViewModel: TransactionViewModel) {
        transactionAnnotationStore.hideTransaction(transactionViewModel.transaction)
        updateSections(for: transactionService.transactions.value)
    }
    
    func updateAnnotation(_ annotation: TransactionAnnotation, for transactionViewModel: TransactionViewModel) {
        transactionAnnotationStore.updateAnnotation(annotation, for: transactionViewModel.transaction)
        transactionViewModel.annotation.value = annotation
    }
    
    // MARK: - Private
    
    private func updateSections(for transactions: [Transaction]) {
        let transactionViewModels = transactions.map {
            TransactionViewModel.instance(for: $0, transactionStore: transactionAnnotationStore, aliasStore: aliasStore)
        }
        
        let result = bondSections(transactionViewModels: transactionViewModels)
        let array = Observable2DArray(result)
        
        DispatchQueue.main.async {
            self.sections.replace(with: array, performDiff: true)
        }
    }

    private func dateWithoutTime(from date: Date) -> Date {
        let components = Calendar.current.dateComponents([.day, .month, .year], from: date)
        return Calendar.current.date(from: components) ?? date
    }

    private func sortedSections(transactionViewModels: [TransactionViewModel]) -> [(Date, [TransactionViewModel])] {
        let grouped = transactionViewModels.grouped { transaction -> Date in
            self.dateWithoutTime(from: transaction.date)
        }

        return Array(zip(grouped.keys, grouped.values))
            .sorted { $0.0 > $1.0 }
    }

    private func bondSections(transactionViewModels: [TransactionViewModel]) -> [Observable2DArraySection<String, TransactionViewModel>] {
        let sortedSections = self.sortedSections(transactionViewModels: transactionViewModels)

        return sortedSections.compactMap {
            let sortedItems = $0.1.sorted { $0.date > $1.date }

            guard let date = $0.1.first?.date else { return nil }

            let dateString = date.localized

            return Observable2DArraySection<String, TransactionViewModel>(
                metadata: dateString,
                items: sortedItems
            )
        }
    }
}
