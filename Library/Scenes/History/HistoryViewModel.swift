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
import SwiftLnd

final class HistoryViewModel: NSObject {
    private let historyService: HistoryService
    
    let isLoading = Observable(true)
    let dataSource: MutableObservable2DArray<String, HistoryEventType>
    let isEmpty: Signal<Bool, NoError>
    
    let searchString = Observable<String?>(nil)
    let filterSettings = Observable<FilterSettings>(FilterSettings.load())
    let isFilterActive: Signal<Bool, NoError>
    
    var lastSeenDate = Date(timeIntervalSinceNow: -60 * 60 * 24 * 2)
    
    public private(set) var notificationCount = 2
    
    init(historyService: HistoryService) {
        self.historyService = historyService
        dataSource = MutableObservable2DArray()

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

//        combineLatest(searchString, filterSettings)
//            .observeNext { [weak self] in
//                self?.filterTransactionViewModels(searchString: $0, filterSettings: $1)
//            }
//            .dispose(in: reactive.bag)
        
        /////// new stuff
        
        let sectionedCellTypes = bondSections(transactionViewModels: historyService.events)
        dataSource.replace(with: Observable2DArray(sectionedCellTypes), performDiff: true)
    }
    
    func setupTabBarBadge(tabBarItem: UITabBarItem) {
        let sortedEvents = historyService.events.sorted(by: { $0.date > $1.date })
        if let unseenEventCount = sortedEvents.firstIndex(where: { $0.date < lastSeenDate }),
            unseenEventCount > 0 {
            tabBarItem.badgeColor = UIColor.Zap.superRed
            tabBarItem.badgeValue = String(unseenEventCount)
        } else {
            tabBarItem.badgeValue = nil
        }
    }
    
//    func refresh() {
//        transactionService.update()
//    }
//
//    func setTransactionHidden(_ transaction: Transaction, hidden: Bool) {
//        let newAnnotation = transactionService.setTransactionHidden(transaction, hidden: hidden)
//        updateAnnotation(newAnnotation, for: transaction)
//
//        if !filterSettings.value.displayArchivedTransactions {
//            filterTransactionViewModels(searchString: searchString.value, filterSettings: filterSettings.value)
//        }
//    }
//
//    func updateAnnotationType(_ type: TransactionAnnotationType, for transaction: Transaction) {
//        let annotation = transactionService.annotation(for: transaction)
//        let newAnnotation = annotation.settingType(to: type)
//        updateAnnotation(newAnnotation, for: transaction)
//    }
//
//    func updateAnnotation(_ annotation: TransactionAnnotation, for transaction: Transaction) {
//        transactionService.updateAnnotation(annotation, for: transaction)
//        for transactionViewModel in transactionViewModels where transactionViewModel.id == transaction.id {
//            transactionViewModel.annotation.value = annotation
//            break
//        }
//    }
//
//    func updateFilterSettings(_ newFilterSettings: FilterSettings) {
//        filterSettings.value = newFilterSettings
//        newFilterSettings.save()
//    }
    
    // MARK: - Private
    
//    private func updateTransactionViewModels(transactions: [Transaction]) {
//        let newTransactionViewModels = transactions
//            .compactMap { transaction -> TransactionViewModel in
//                let annotation = transactionService.annotation(for: transaction)
//
//                if let oldTransactionViewModel = self.transactionViewModels.first(where: { $0.transaction.isTransactionEqual(to: transaction) }) {
//                    return oldTransactionViewModel
//                } else {
//                    return TransactionViewModel.instance(for: transaction, annotation: annotation, nodeStore: nodeStore)
//                }
//            }
//
//        transactionViewModels = newTransactionViewModels
//        filterTransactionViewModels(searchString: searchString.value, filterSettings: filterSettings.value)
//    }
//
//    private func filterTransactionViewModels(searchString: String?, filterSettings: FilterSettings) {
//        let filteredTransactionViewModels = transactionViewModels
//            .filter { $0.matchesFilterSettings(filterSettings) }
//            .filter { $0.matchesSearchString(searchString) }
//
//        let result = bondSections(transactionViewModels: filteredTransactionViewModels)
//
//        DispatchQueue.main.async {
//            self.dataSource.replace(with: result, performDiff: true)
//            self.isLoading.value = false
//        }
//    }
//
    private func sortedSections(transactionViewModels: [HistoryEventType]) -> [(Date, [HistoryEventType])] {
        let grouped = transactionViewModels
            .grouped { transaction -> Date in
                transaction.date.withoutTime
            }
    
        return Array(zip(grouped.keys, grouped.values))
            .sorted { $0.0 > $1.0 }
    }

    private func bondSections(transactionViewModels: [HistoryEventType]) -> [Observable2DArraySection<String, HistoryEventType>] {
        let sortedSections = self.sortedSections(transactionViewModels: transactionViewModels)
        
        return sortedSections.compactMap {
            let sortedItems = $0.1.sorted { $0.date > $1.date }
            
            guard let date = $0.1.first?.date else { return nil }
            
            let dateString = date.localized
            
            return Observable2DArraySection<String, HistoryEventType>(
                metadata: dateString,
                items: sortedItems
            )
        }
    }
}
