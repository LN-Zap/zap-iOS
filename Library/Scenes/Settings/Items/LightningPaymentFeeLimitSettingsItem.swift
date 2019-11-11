//
//  Library
//
//  Created by Christopher Pinski on 10/12/19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Bond
import Foundation
import SwiftLnd

final class LightningPaymentFeeLimitSelectionSettingsItem: DetailDisclosureSettingsItem, SubtitleSettingsItem {
    let subtitle = Settings.shared.lightningPaymentFeeLimit.map { Optional($0.localized) }

    let title = L10n.Scene.Settings.Item.lightningPaymentFeeLimit

    func didSelectItem(from fromViewController: UIViewController) {
        let items: [SettingsItem] = PaymentFeeLimitPercentage.allCases.map { LightningPaymentFeeLimitSettingsItem(percentage: $0) }
        let section = Section(title: nil, rows: items)

        let viewController = GroupedTableViewController(sections: [section])
        viewController.title = title
        viewController.navigationItem.largeTitleDisplayMode = .never

        fromViewController.navigationController?.show(viewController, sender: nil)
    }
}

final class LightningPaymentFeeLimitSettingsItem: NSObject, SelectableSettingsItem {
    var isSelectedOption = Observable(false)

    let title: String
    private let percentage: PaymentFeeLimitPercentage

    init(percentage: PaymentFeeLimitPercentage) {
        self.percentage = percentage
        title = percentage.localized
        super.init()

        Settings.shared.lightningPaymentFeeLimit
            .observeNext { [isSelectedOption] currentPercentage in
                isSelectedOption.value = currentPercentage == percentage
            }
            .dispose(in: reactive.bag)
    }

    func didSelectItem(from fromViewController: UIViewController) {
        Settings.shared.lightningPaymentFeeLimit.value = percentage
    }
}
