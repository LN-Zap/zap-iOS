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

    let dataSource: MutableObservableArray2D<String, HistoryEventType>

    var searchString: String? {
        didSet {
            updateEvents()
        }
    }
    var filterSettings = FilterSettings.load() {
        didSet {
            updateEvents()
            filterSettings.save()
        }
    }

    private var currentLastSeenDate: Date?
    private var lastSeenDate: Date {
        get {
            return UserDefaults.Keys.lastSeenHistoryDate.get(defaultValue: Date(timeIntervalSince1970: 0))
        }
        set {
            UserDefaults.Keys.lastSeenHistoryDate.set(newValue)
        }
    }

    init(historyService: HistoryService) {
        self.historyService = historyService
        dataSource = MutableObservableArray2D(Array2D())

        super.init()

        historyService.events
            .observeNext { [weak self] _ in
                self?.updateEvents()
            }
            .dispose(in: reactive.bag)
    }

    func isNew(event: HistoryEventType) -> Bool {
        guard let currentLastSeenDate = currentLastSeenDate else { return false }
        return event.date > currentLastSeenDate
    }

    func historyWillAppear() {
        currentLastSeenDate = lastSeenDate
        lastSeenDate = Date()
    }

    private func updateEvents() {
        let events = historyService.events.array
        let filteredEvents = filterEvents(events, searchString: searchString, filterSettings: filterSettings)
        let sectionedCellTypes = bondSections(transactionViewModels: filteredEvents)
        dataSource.replace(with: Array2D<String, HistoryEventType>(sections: sectionedCellTypes), performDiff: true, areEqual: Array2D.areEqual)
    }

    private func filterEvents(_ events: [HistoryEventType], searchString: String?, filterSettings: FilterSettings) -> [HistoryEventType] {
        return events
            .filter { $0.matchesFilterSettings(filterSettings) }
            .filter { $0.matchesSearchString(searchString) }
    }

    private func sortedSections(transactionViewModels: [HistoryEventType]) -> [(Date, [HistoryEventType])] {
        let grouped = transactionViewModels
            .grouped { transaction -> Date in
                transaction.date.withoutTime
            }

        return Array(zip(grouped.keys, grouped.values))
            .sorted { $0.0 > $1.0 }
    }

    private func bondSections(transactionViewModels: [HistoryEventType]) -> [Array2D<String, HistoryEventType>.Section] {
        let sortedSections = self.sortedSections(transactionViewModels: transactionViewModels)

        return sortedSections.compactMap {
            let sortedItems = $0.1.sorted { $0.date > $1.date }

            guard let date = $0.1.first?.date else { return nil }

            let dateString = date.localized

            return Array2D<String, HistoryEventType>.Section(metadata: dateString, items: sortedItems)
        }
    }
    
    func refresh() {
        historyService.refresh()
    }
}

extension HistoryEventType {
    func matchesFilterSettings(_ filterSettings: FilterSettings) -> Bool {
        switch self {
        case .transactionEvent:
            return filterSettings.transactionEvents
        case .channelEvent:
            return filterSettings.channelEvents
        case .createInvoiceEvent(let event):
            return filterSettings.createInvoiceEvents && (filterSettings.expiredInvoiceEvents || !event.isExpired || event.state == .settled)
        case .lightningPaymentEvent:
            return filterSettings.lightningPaymentEvents
        }
    }

    func matchesSearchString(_ searchString: String?) -> Bool {
        guard
            let searchString = searchString,
            !searchString.isEmpty
            else { return true }

        switch self {
        case .transactionEvent(let event):
            return matches(content: [event.txHash], searchString: searchString)
        case .channelEvent(let event):
            return matches(content: [event.node.pubKey, event.node.alias], searchString: searchString)
        case .createInvoiceEvent(let event):
            return matches(content: [event.memo], searchString: searchString)
        case .lightningPaymentEvent(let event):
            return matches(content: [event.node.pubKey, event.node.alias], searchString: searchString)
        }
    }

    private func matches(content: [String?], searchString: String) -> Bool {
        let searchString = searchString.lowercased()
        for string in content {
            guard let string = string else { continue }
            if string.lowercased().contains(searchString) {
                return true
            }
        }
        return false
    }
}
