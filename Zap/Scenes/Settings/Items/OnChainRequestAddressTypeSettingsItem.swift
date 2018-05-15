//
//  Zap
//
//  Created by Otto Suess on 15.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation

enum OnChainRequestAddressType: Localizable {
    case witnessPubkeyHash
    case nestedPubkeyHash
    
    var localized: String {
        switch self {
        case .witnessPubkeyHash:
            return "Bech32"
        case .nestedPubkeyHash:
            return "P2SH"
        }
    }
}

// swiftlint:disable:next type_name
final class OnChainRequestAddressTypeSelectionSettingsItem: DetailDisclosureSettingsItem, SubtitleSettingsItem {
    var subtitle = Settings.onChainRequestAddressType.map { Optional($0.localized) }
    
    let title = "Bitcoin Address Type"
    
    func didSelectItem(from fromViewController: UIViewController) {
        let items: [SettingsItem] = [
            OnChainRequestAddressTypeSettingsItem(onChainRequestAddressType: .nestedPubkeyHash),
            OnChainRequestAddressTypeSettingsItem(onChainRequestAddressType: .witnessPubkeyHash)
        ]
        let section = Section(title: nil, rows: items)
        
        let viewController = GroupedTableViewController(sections: [section])
        viewController.title = title
        viewController.navigationItem.largeTitleDisplayMode = .never
        
        fromViewController.navigationController?.show(viewController, sender: nil)
    }
}

final class OnChainRequestAddressTypeSettingsItem: NSObject, SelectableSettingsItem {
    var isSelectedOption = Observable(false)
    
    let title: String
    private let onChainRequestAddressType: OnChainRequestAddressType
    
    init(onChainRequestAddressType: OnChainRequestAddressType) {
        self.onChainRequestAddressType = onChainRequestAddressType
        title = onChainRequestAddressType.localized
        super.init()
        
        Settings.onChainRequestAddressType
            .observeNext {  [isSelectedOption] currentType in
                isSelectedOption.value = currentType == onChainRequestAddressType
            }
            .dispose(in: reactive.bag)
    }
    
    func didSelectItem(from fromViewController: UIViewController) {
        Settings.onChainRequestAddressType.value = onChainRequestAddressType
    }
}
