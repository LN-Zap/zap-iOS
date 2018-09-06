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

enum HeaderTableCellType<Value: Equatable>: Equatable {
    case header(String)
    case cell(Value)
}

final class TransactionListViewModel: NSObject {
    private let transactionService: TransactionService
    private let nodeStore: LightningNodeStore
    let transactionAnnotationStore = TransactionAnnotationStore()
    
    let isLoading = Observable(true)
    let dataSource: MutableObservableArray<HeaderTableCellType<TransactionViewModel>>
    let isEmpty: Signal<Bool, NoError>
    
    let searchString = Observable<String?>(nil)
    let filterSettings = Observable<FilterSettings>(FilterSettings.load())
    let isFilterActive: Signal<Bool, NoError>
    
    private var transactionViewModels = [TransactionViewModel]()
    
    init(transactionService: TransactionService, nodeStore: LightningNodeStore) {
        self.transactionService = transactionService
        self.nodeStore = nodeStore
        dataSource = MutableObservableArray()
        
        isEmpty =
            combineLatest(dataSource, isLoading) { sections, isLoading in
                sections.dataSource.isEmpty && !isLoading
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
                    return TransactionViewModel.instance(for: transaction, annotation: annotation, nodeStore: nodeStore)
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
        
        DispatchQueue.main.async {
            self.dataSource.replace(with: result, performDiff: true)
            self.isLoading.value = false
        }
    }
    
    private func sortedSections(transactionViewModels: [TransactionViewModel]) -> [(Date, [TransactionViewModel])] {
        let grouped = transactionViewModels.grouped { transaction -> Date in
            transaction.date.withoutTime
        }

        return Array(zip(grouped.keys, grouped.values))
            .sorted { $0.0 > $1.0 }
    }

    private func bondSections(transactionViewModels: [TransactionViewModel]) -> [HeaderTableCellType<TransactionViewModel>] {
        let sortedSections = self.sortedSections(transactionViewModels: transactionViewModels)

        return sortedSections.flatMap { input -> [HeaderTableCellType<TransactionViewModel>] in
            let sortedItems = input.1.sorted { $0.date > $1.date }
            guard let date = input.1.first?.date else { return [] }
            let dateString = date.localized
            return [HeaderTableCellType.header(dateString)] + sortedItems.map { HeaderTableCellType.cell($0) }
        }
    }
}
