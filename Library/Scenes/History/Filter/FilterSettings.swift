//
//  Library
//
//  Created by Otto Suess on 04.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import Lightning

struct FilterSettings: Equatable, Codable {
    var channelEvents: Bool
    var transactionEvents: Bool
    var createInvoiceEvents: Bool
    var expiredInvoiceEvents: Bool
    var lightningPaymentEvents: Bool
}

extension FilterSettings {
    static var fileName = "filterSettings"

    init() {
        channelEvents = true
        transactionEvents = true
        createInvoiceEvents = true
        expiredInvoiceEvents = false
        lightningPaymentEvents = true
    }

    public func save() {
        Storage.store(self, to: FilterSettings.fileName)
    }

    public static func load() -> FilterSettings {
        return Storage.restore(fileName) ?? FilterSettings()
    }
}

enum FilterSetting: Localizable {
    case channelEvents
    case transactionEvents
    case createInvoiceEvents
    case expiredInvoiceEvents
    case lightningPaymentEvents

    var localized: String {
        switch self {
        case .transactionEvents:
            return L10n.Scene.Filter.displayOnChainTransactions
        case .lightningPaymentEvents:
            return L10n.Scene.Filter.displayLightningPayments
        case .createInvoiceEvents:
            return L10n.Scene.Filter.displayLightningInvoices
        case .channelEvents:
            return L10n.Scene.Filter.displayChannelEvents
        case .expiredInvoiceEvents:
            return L10n.Scene.Filter.displayExpiredInvoices
        }
    }

    private var keyPath: WritableKeyPath<FilterSettings, Bool> {
        switch self {
        case .channelEvents:
            return \.channelEvents
        case .transactionEvents:
            return \.transactionEvents
        case .createInvoiceEvents:
            return \.createInvoiceEvents
        case .expiredInvoiceEvents:
            return \.expiredInvoiceEvents
        case .lightningPaymentEvents:
            return \.lightningPaymentEvents
        }
    }

    func isActive(in filterSettings: FilterSettings) -> Bool {
        return filterSettings[keyPath: keyPath]
    }

    func setActive(_ isActive: Bool, in filterSettings: FilterSettings) -> FilterSettings {
        var filterSettings = filterSettings
        filterSettings[keyPath: keyPath] = isActive
        return filterSettings
    }
}
