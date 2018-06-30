//
//  Zap
//
//  Created by Otto Suess on 19.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import BTCUtil
import Foundation
import ReactiveKit

final class CurrencySelectionSettingsItem: DetailDisclosureSettingsItem, SubtitleSettingsItem {
    let subtitle = Settings.shared.fiatCurrency.map { Optional($0.localized) }
    
    let title = "scene.settings.item.currency".localized
    
    func didSelectItem(from fromViewController: UIViewController) {
        let allCurrencies = ExchangeData.availableCurrencies?
            .sorted { $0.localized < $1.localized }
            .map { CurrencySettingsItem(currency: $0) } ?? []
        
        let items: [SettingsItem] = allCurrencies

        let section = Section(title: nil, rows: items)
        
        let viewController = GroupedTableViewController(sections: [section])
        viewController.title = title
        viewController.navigationItem.largeTitleDisplayMode = .never

        fromViewController.navigationController?.show(viewController, sender: nil)
    }
}

final class CurrencySettingsItem: NSObject, SelectableSettingsItem {
    var isSelectedOption = Observable(false)
    
    let title: String
    private let currency: FiatCurrency
    
    init(currency: FiatCurrency) {
        self.currency = currency
        title = "\(currency.localized) (\(currency.symbol))"
        super.init()
        
        Settings.shared.fiatCurrency
            .observeNext { [isSelectedOption] currentCurrency in
                isSelectedOption.value = currentCurrency.currencyCode == currency.currencyCode
            }
            .dispose(in: reactive.bag)
    }
    
    func didSelectItem(from fromViewController: UIViewController) {
        Settings.shared.updateCurrency(currency)
    }
}
