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
    func updateBadgeValue(_ value: Int)
}

final class HistoryViewModel: NSObject {
    private let historyService: HistoryService

    weak var delegate: HistoryBadgeUpdaterDelegate?

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
        dataSource = MutableObservableArray2D()

        super.init()

        updateEvents()

        NotificationCenter.default.addObserver(self, selector: #selector(updateEvents), name: .historyDidChange, object: nil)
    }

    func isEventNew(at indexPath: IndexPath) -> Bool {
        guard let currentLastSeenDate = currentLastSeenDate else {
            return false
        }
        return dataSource.collection.item(at: indexPath).date > currentLastSeenDate
    }

    func historyWillAppear() {
        delegate?.updateBadgeValue(0)
        currentLastSeenDate = lastSeenDate
        lastSeenDate = Date()
    }

    @objc private func updateEvents() {
        let events = historyService.events
        let filteredEvents = filterEvents(events, searchString: searchString, filterSettings: filterSettings)
        let sectionedCellTypes = bondSections(transactionViewModels: filteredEvents)

        dataSource.replace(with: Array2D<String, HistoryEventType>(sectionedCellTypes), performDiff: true, areValuesEqual: evaluateEqual)
        updateTabBarBadge()
    }

    private func evaluateEqual(one: Array2DElement<String, HistoryEventType>, two: Array2DElement<String, HistoryEventType>) -> Bool {
        return one.section == two.section && one.item == two.item
    }

    func setupTabBarBadge(delegate: HistoryBadgeUpdaterDelegate) {
        self.delegate = delegate
        updateTabBarBadge()
    }

    private func updateTabBarBadge() {
        guard let delegate = delegate else { return }

        var unseenEventCount = 0

        sectionLoop: for dayNode in dataSource.collection.children {
            for historyEventNode in dayNode.children {
                guard let item = historyEventNode.value.item else {
                    continue
                }

                if item.date > lastSeenDate {
                    unseenEventCount += 1
                } else {
                    break sectionLoop
                }
            }
        }

        delegate.updateBadgeValue(unseenEventCount)
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

    private func bondSections(transactionViewModels: [HistoryEventType]) -> [TreeNode<Array2DElement<String, HistoryEventType>>] {
        let sortedSections = self.sortedSections(transactionViewModels: transactionViewModels)

        return sortedSections.compactMap {
            let sortedItems = $0.1.sorted { $0.date > $1.date }

            guard let date = $0.1.first?.date else { return nil }

            let dateString = date.localized

            return to2DArraySection(section: dateString, items: sortedItems)
        }
    }
}

extension HistoryEventType {
    func matchesFilterSettings(_ filterSettings: FilterSettings) -> Bool {
        switch self {
        case .transactionEvent(let event):
            return filterSettings.transactionEvents && (event.type != .unknown || filterSettings.unknownTransactionType)
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
            return matches(content: [event.channelEvent.node.pubKey, event.channelEvent.node.alias], searchString: searchString)
        case .createInvoiceEvent(let event):
            return matches(content: [event.memo], searchString: searchString)
        case .failedPaymentEvent(let event):
            return matches(content: [event.memo], searchString: searchString)
        case .lightningPaymentEvent(let event):
            return matches(content: [event.memo], searchString: searchString)
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
