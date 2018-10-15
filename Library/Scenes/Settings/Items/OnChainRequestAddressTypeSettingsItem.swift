//
//  Zap
//
//  Created by Otto Suess on 15.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning
import SwiftLnd

extension OnChainRequestAddressType: Localizable {
    public var localized: String {
        switch self {
        case .witnessPubkeyHash:
            return "scene.settings.item.on_chain_request_address.bech32".localized
        case .nestedPubkeyHash:
            return "scene.settings.item.on_chain_request_address.p2sh".localized
        }
    }
}

// swiftlint:disable:next type_name
final class OnChainRequestAddressTypeSelectionSettingsItem: DetailDisclosureSettingsItem, SubtitleSettingsItem {
    var subtitle = Settings.shared.onChainRequestAddressType.map { Optional($0.localized) }
    
    let title = "scene.settings.item.on_chain_request_address.title".localized
    
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
        
        Settings.shared.onChainRequestAddressType
            .observeNext {  [isSelectedOption] currentType in
                isSelectedOption.value = currentType == onChainRequestAddressType
            }
            .dispose(in: reactive.bag)
    }
    
    func didSelectItem(from fromViewController: UIViewController) {
        Settings.shared.onChainRequestAddressType.value = onChainRequestAddressType
    }
}
