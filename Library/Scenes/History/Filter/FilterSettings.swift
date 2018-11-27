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
    var unknownTransactionType: Bool
    var createInvoiceEvents: Bool
    var failedPaymentEvents: Bool
    var lightningPaymentEvents: Bool
}

extension FilterSettings {
    static var fileName = "filterSettings"
    
    init() {
        channelEvents = true
        transactionEvents = true
        unknownTransactionType = false
        createInvoiceEvents = true
        failedPaymentEvents = true
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
    case unknownTransactionType
    case createInvoiceEvents
    case failedPaymentEvents
    case lightningPaymentEvents
    
    var localized: String {
        switch self {
        case .transactionEvents:
            return L10n.Scene.Filter.displayOnChainTransactions
        case .unknownTransactionType:
            return L10n.Scene.Filter.displayUnknownTransactionType
        case .lightningPaymentEvents:
            return L10n.Scene.Filter.displayLightningPayments
        case .createInvoiceEvents:
            return L10n.Scene.Filter.displayLightningInvoices
        case .failedPaymentEvents:
            return L10n.Scene.Filter.displayFailedPaymentEvents
        case .channelEvents:
            return L10n.Scene.Filter.displayChannelEvents
        }
    }
    
    func isActive(in filterSettings: FilterSettings) -> Bool {
        switch self {
        case .transactionEvents:
            return filterSettings.transactionEvents
        case .lightningPaymentEvents:
            return filterSettings.lightningPaymentEvents
        case .createInvoiceEvents:
            return filterSettings.createInvoiceEvents
        case .channelEvents:
            return filterSettings.channelEvents
        case .failedPaymentEvents:
            return filterSettings.failedPaymentEvents
        case .unknownTransactionType:
            return filterSettings.unknownTransactionType
        }
    }
    
    func setActive(_ isActive: Bool, in filterSettings: FilterSettings) -> FilterSettings {
        var filterSettings = filterSettings
        
        switch self {
        case .transactionEvents:
            filterSettings.transactionEvents = isActive
        case .lightningPaymentEvents:
            filterSettings.lightningPaymentEvents = isActive
        case .createInvoiceEvents:
            filterSettings.createInvoiceEvents = isActive
        case .channelEvents:
            filterSettings.channelEvents = isActive
        case .failedPaymentEvents:
            filterSettings.failedPaymentEvents = isActive
        case .unknownTransactionType:
            filterSettings.unknownTransactionType = isActive
        }
        return filterSettings
    }
}
