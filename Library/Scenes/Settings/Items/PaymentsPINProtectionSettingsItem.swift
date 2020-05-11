//
//  Library
//
//  Created by Ivan Kuznetsov on 11.05.2020.
//  Copyright © 2020 Zap. All rights reserved.
//

import Bond
import UIKit

final class PaymentsPINProtectionSettingsItem: NSObject, ToggleSettingsItem {
    var isToggled = Observable(Settings.shared.paymentsPINProtection.value)
    
    let title = L10n.Scene.Settings.Item.paymentsPinProtection
    
    override init() {
        super.init()
        
        isToggled.bind(to: Settings.shared.paymentsPINProtection).dispose(in: reactive.bag)
    }
    
    func didSelectItem(from fromViewController: UIViewController) {
    }
}
