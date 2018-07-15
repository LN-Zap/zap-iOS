//
//  Zap
//
//  Created by Otto Suess on 28.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Foundation
import Lightning
import ReactiveKit

final class TransactionListViewModel: NSObject {
    private let transactionService: TransactionService
    private let aliasStore: ChannelAliasStore
    let transactionAnnotationStore = TransactionAnnotationStore()
    
    let isLoading = Observable(true)
    let sections: MutableObservable2DArray<String, TransactionViewModel>
    let isEmpty: Signal<Bool, NoError>
    
    let searchString = Observable<String?>(nil)
    let filterSettings = Observable<FilterSettings>(FilterSettings.load())
    let isFilterActive: Signal<Bool, NoError>
    
    private var transactionViewModels = [TransactionViewModel]()
    
    init(transactionService: TransactionService, aliasStore: ChannelAliasStore) {
        self.transactionService = transactionService
        self.aliasStore = aliasStore
        sections = MutableObservable2DArray()
        
        isEmpty =
            combineLatest(sections, isLoading) { sections, isLoading in
                return sections.dataSource.isEmpty && !isLoading
            }
            .distinct()
            .debounce(interval: 0.5)
            .start(with: false)

        isFilterActive = filterSettings
            .map { $0 != FilterSettings() }
        
        super.init()
        
        transactionService.transactions
            .observeNext { [weak self] in
                self?.updateTransactionViewModels(transactions: $0)
            }
            .dispose(in: reactive.bag)
        
        combineLatest(searchString, filterSettings)
            .observeNext { [weak self] in
                self?.filterTransactionViewModels(searchString: $0, filterSettings: $1)
            }
            .dispose(in: reactive.bag)
    }
    
    func refresh() {
        transactionService.update()
    }
    
    func setTransactionHidden(_ transaction: Transaction, hidden: Bool) {
        let newAnnotation = transactionAnnotationStore.setTransactionHidden(transaction, hidden: hidden)
        updateAnnotation(newAnnotation, for: transaction)
        
        if !filterSettings.value.displayArchivedTransactions {
            filterTransactionViewModels(searchString: searchString.value, filterSettings: filterSettings.value)
        }
    }
    
    func updateAnnotationType(_ type: TransactionAnnotationType, for transaction: Transaction) {
        let annotation = transactionAnnotationStore.annotation(for: transaction)
        let newAnnotation = annotation.settingType(to: type)
        updateAnnotation(newAnnotation, for: transaction)
    }
    
    func updateAnnotation(_ annotation: TransactionAnnotation, for transaction: Transaction) {
        transactionAnnotationStore.updateAnnotation(annotation, for: transaction)
        for transactionViewModel in transactionViewModels where transactionViewModel.id == transaction.id {
            transactionViewModel.annotation.value = annotation
            break
        }
    }
    
    func updateFilterSettings(_ newFilterSettings: FilterSettings) {
        filterSettings.value = newFilterSettings
        newFilterSettings.save()
    }
    
    // MARK: - Private
    
    private func updateTransactionViewModels(transactions: [Transaction]) {
        let newTransactionViewModels = transactions
            .compactMap { transaction -> TransactionViewModel in
                let annotation = transactionAnnotationStore.annotation(for: transaction)
                
                if let oldTransactionViewModel = self.transactionViewModels.first(where: { $0.transaction.isTransactionEqual(to: transaction) }) {
                    return oldTransactionViewModel
                } else {
                    return TransactionViewModel.instance(for: transaction, annotation: annotation, aliasStore: aliasStore)
                }
            }
        
        transactionViewModels = newTransactionViewModels
        filterTransactionViewModels(searchString: searchString.value, filterSettings: filterSettings.value)
    }
    
    private func filterTransactionViewModels(searchString: String?, filterSettings: FilterSettings) {
        let filteredTransactionViewModels = transactionViewModels
            .filter { $0.matchesFilterSettings(filterSettings) }
            .filter { $0.matchesSearchString(searchString) }
        
        let result = bondSections(transactionViewModels: filteredTransactionViewModels)
        let array = Observable2DArray(result)
        
        DispatchQueue.main.async {
            self.sections.replace(with: array, performDiff: true)
            self.isLoading.value = false
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
