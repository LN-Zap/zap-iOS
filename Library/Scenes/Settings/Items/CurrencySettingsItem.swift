//
//  Zap
//
//  Created by Otto Suess on 19.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import SwiftBTC

final class CurrencySelectionSettingsItem: DetailDisclosureSettingsItem, SubtitleSettingsItem {
    let subtitle = Settings.shared.fiatCurrency.map { Optional($0.localized) }

    let title = L10n.Scene.Settings.Item.currency

    func didSelectItem(from fromViewController: UIViewController) {
        let items = ExchangeData.availableCurrencies?
            .sorted { $0.localized < $1.localized }
            .map { CurrencySettingsItem(currency: $0) } ?? []

        var popularCurrencies: [CurrencySettingsItem] = []
        var allCurrencies: [SettingsItem] = []

        let popularCodes = ["USD", "EUR", "GBP", "JPY", "CNY"]
        for item in items {
            if popularCodes.contains(item.currency.currencyCode) {
                popularCurrencies.append(item)
            } else {
                allCurrencies.append(item)
            }
        }

        popularCurrencies.sort {
            (popularCodes.firstIndex(of: $0.currency.currencyCode) ?? 0) < popularCodes.firstIndex(of: $1.currency.currencyCode) ?? 0
        }

        let popularSection = Section<SettingsItem>(title: L10n.Scene.Settings.Item.Currency.popular, rows: popularCurrencies)
        let section = Section(title: nil, rows: allCurrencies)

        let viewController = GroupedTableViewController(sections: [
            popularSection,
            section
        ])

        viewController.title = title
        viewController.navigationItem.largeTitleDisplayMode = .never

        fromViewController.navigationController?.show(viewController, sender: nil)
    }
}

final class CurrencySettingsItem: NSObject, SelectableSettingsItem {
    var isSelectedOption = Observable(false)

    let title: String
    let currency: FiatCurrency

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
