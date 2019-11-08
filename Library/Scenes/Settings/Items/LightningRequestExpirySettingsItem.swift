//
//  Library
//
//  Created by Christopher Pinski on 10/7/19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Bond
import Foundation
import SwiftLnd

final class LightningRequestExpirySelectionSettingsItem: DetailDisclosureSettingsItem, SubtitleSettingsItem { // swiftlint:disable:this type_name
    let subtitle = Settings.shared.lightningRequestExpiry.map { Optional($0.localized) }

    let title = L10n.Scene.Settings.Item.lightningRequestExpiry

    func didSelectItem(from fromViewController: UIViewController) {
        let items: [SettingsItem] = ExpiryTime.allCases.map { LightningRequestExpirySettingsItem(expiryTime: $0) }
        let section = Section(title: nil, rows: items)

        let viewController = GroupedTableViewController(sections: [section])
        viewController.title = title
        viewController.navigationItem.largeTitleDisplayMode = .never

        fromViewController.navigationController?.show(viewController, sender: nil)
    }
}

final class LightningRequestExpirySettingsItem: NSObject, SelectableSettingsItem {
    var isSelectedOption = Observable(false)

    let title: String
    private let expiryTime: ExpiryTime

    init(expiryTime: ExpiryTime) {
        self.expiryTime = expiryTime
        title = "\(expiryTime.localized)"
        super.init()

        Settings.shared.lightningRequestExpiry
            .observeNext { [isSelectedOption] currenteExpiryTime in
                isSelectedOption.value = currenteExpiryTime == expiryTime
            }
            .dispose(in: reactive.bag)
    }

    func didSelectItem(from fromViewController: UIViewController) {
        Settings.shared.lightningRequestExpiry.value = expiryTime
    }
}
