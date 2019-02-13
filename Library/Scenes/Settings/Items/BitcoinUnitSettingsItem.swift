//
//  Zap
//
//  Created by Otto Suess on 19.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Foundation
import SwiftBTC

final class BitcoinUnitSelectionSettingsItem: DetailDisclosureSettingsItem, SubtitleSettingsItem {
    let subtitle = Settings.shared.cryptoCurrency.map { Optional($0.localized) }
    
    let title = L10n.Scene.Settings.Item.bitcoinUnit

    func didSelectItem(from fromViewController: UIViewController) {
        let items: [SettingsItem] = Bitcoin.allCases.map { BitcoinUnitSettingsItem(currency: $0) }
        let section = Section(title: nil, rows: items)
        
        let viewController = GroupedTableViewController(sections: [section])
        viewController.title = title
        viewController.navigationItem.largeTitleDisplayMode = .never
        
        fromViewController.navigationController?.show(viewController, sender: nil)
    }
}

final class BitcoinUnitSettingsItem: NSObject, SelectableSettingsItem {
    var isSelectedOption = Observable(false)
    
    let title: String
    private let currency: Bitcoin
    
    init(currency: Bitcoin) {
        self.currency = currency
        title = "\(currency.localized) (\(currency.symbol))"
        super.init()
        
        Settings.shared.cryptoCurrency
            .observeNext { [isSelectedOption] currentCurrency in
                isSelectedOption.value = currentCurrency == currency
            }
            .dispose(in: reactive.bag)
    }
    
    func didSelectItem(from fromViewController: UIViewController) {
        Settings.shared.updateCurrency(currency)
    }
}
