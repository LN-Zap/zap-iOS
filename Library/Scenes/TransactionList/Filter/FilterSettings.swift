//
//  Library
//
//  Created by Otto Suess on 04.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

struct FilterSettings: Equatable {
    var displayOnChainTransactions = true
    var displayLightningPayments = true
    var displayLightningInvoices = true
    var displayArchivedTransactions = false
}

enum FilterSetting: Localizable {
    case displayOnChainTransactions
    case displayLightningPayments
    case displayLightningInvoices
    case displayArchivedTransactions
    
    var localized: String {
        switch self {
        case .displayOnChainTransactions:
            return "scene.filter.displayOnChainTransactions".localized
        case .displayLightningPayments:
            return "scene.filter.displayLightningPayments".localized
        case .displayLightningInvoices:
            return "scene.filter.displayLightningInvoices".localized
        case .displayArchivedTransactions:
            return "scene.filter.displayArchivedTransactions".localized
        }
    }
    
    func isActive(in filterSettings: FilterSettings) -> Bool {
        switch self {
        case .displayOnChainTransactions:
            return filterSettings.displayOnChainTransactions
        case .displayLightningPayments:
            return filterSettings.displayLightningPayments
        case .displayLightningInvoices:
            return filterSettings.displayLightningInvoices
        case .displayArchivedTransactions:
            return filterSettings.displayArchivedTransactions
        }
    }
    
    func setActive(_ isActive: Bool, in filterSettings: FilterSettings) -> FilterSettings {
        var filterSettings = filterSettings
        
        switch self {
        case .displayOnChainTransactions:
            filterSettings.displayOnChainTransactions = isActive
        case .displayLightningPayments:
            filterSettings.displayLightningPayments = isActive
        case .displayLightningInvoices:
            filterSettings.displayLightningInvoices = isActive
        case .displayArchivedTransactions:
            filterSettings.displayArchivedTransactions = isActive
        }
        return filterSettings
    }
}
