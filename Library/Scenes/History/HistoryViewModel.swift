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

protocol HistoryBadgeUpdaterDelegate: class {
    func updateBadgeCount(_ value: Int)
}

final class HistoryViewModel: NSObject {
    private let historyService: HistoryService
    
    weak var delegate: HistoryBadgeUpdaterDelegate?
    
    let dataSource: MutableObservable2DArray<String, HistoryEventType>
    
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
    
    var lastSeenDate: Date {
        get {
            return UserDefaults.Keys.lastSeenHistoryDate.get(defaultValue: Date(timeIntervalSince1970: 0))
        }
        set {
            UserDefaults.Keys.lastSeenHistoryDate.set(newValue)
        }
    }
    
    public private(set) var notificationCount = 2
    
    init(historyService: HistoryService) {
        self.historyService = historyService
        dataSource = MutableObservable2DArray()

        super.init()
        
        updateEvents()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateEvents), name: .historyDidChange, object: nil)
    }
    
    @objc private func updateEvents() {
        let events = historyService.events
        let filteredEvents = filterEvents(events, searchString: searchString, filterSettings: filterSettings)
        let sectionedCellTypes = bondSections(transactionViewModels: filteredEvents)
        dataSource.replace(with: Observable2DArray(sectionedCellTypes), performDiff: true)
        updateTabBarBadge()
    }
    
    func setupTabBarBadge(delegate: HistoryBadgeUpdaterDelegate) {
        self.delegate = delegate
        updateTabBarBadge()
    }
    
    private func updateTabBarBadge() {
        guard let delegate = delegate else { return }
        
        let sortedEvents = historyService.events.sorted(by: { $0.date > $1.date })
        if let unseenEventCount = sortedEvents.firstIndex(where: { $0.date < lastSeenDate }),
            unseenEventCount > 0 {
            delegate.updateBadgeCount(unseenEventCount)
        } else {
            delegate.updateBadgeCount(0)
        }
    }
    
    // MARK: - Private

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

extension HistoryEventType {
    func matchesFilterSettings(_ filterSettings: FilterSettings) -> Bool {
        switch self {
        case .transactionEvent:
            return filterSettings.transactionEvents
        case .channelEvent:
            return filterSettings.channelEvents
        case .createInvoiceEvent:
            return filterSettings.createInvoiceEvents
        case .failedPaymentEvent:
            return filterSettings.failedPaymentEvents
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
            return matches(content: [event.memo, event.txHash], searchString: searchString)
        case .channelEvent(let event):
            return matches(content: [event.channelEvent.node.pubKey], searchString: searchString)
        case .createInvoiceEvent(let event):
            return matches(content: [event.memo], searchString: searchString)
        case .failedPaymentEvent(let event):
            return matches(content: [event.memo], searchString: searchString)
        case .lightningPaymentEvent(let event):
            return matches(content: [event.memo], searchString: searchString)
        }
    }
    
    private func matches(content: [String?], searchString: String) -> Bool {
        for string in content {
            guard let string = string else { continue }
            if string.contains(searchString) {
                return true
            }
        }
        return false
    }
}
