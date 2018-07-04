//
//  Library
//
//  Created by Otto Suess on 04.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import Lightning

struct FilterSettings: Equatable, Codable {
    var displayOnChainTransactions: Bool
    var displayLightningPayments: Bool
    var displayLightningInvoices: Bool
    var displayArchivedTransactions: Bool
}

extension FilterSettings {
    init() {
        displayOnChainTransactions = true
        displayLightningPayments = true
        displayLightningInvoices = true
        displayArchivedTransactions = false
    }
    
    private static var plistUrl: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("filterSettings.plist")
    }
    
    public func save() {
        guard
            let encoded = try? PropertyListEncoder().encode(self),
            let url = FilterSettings.plistUrl
            else { return }
        try? encoded.write(to: url)
    }
    
    public static func load() -> FilterSettings {
        guard
            let url = plistUrl,
            let data = try? Data(contentsOf: url),
            let decoded = try? PropertyListDecoder().decode(FilterSettings.self, from: data) else { return FilterSettings() }
        return decoded
    }
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
