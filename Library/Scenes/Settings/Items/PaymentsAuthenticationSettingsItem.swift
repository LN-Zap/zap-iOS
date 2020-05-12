//
//  Library
//
//  Created by Ivan Kuznetsov on 11.05.2020.
//  Copyright © 2020 Zap. All rights reserved.
//

import Bond
import UIKit

final class PaymentsAuthenticationSettingsItem: NSObject, ToggleSettingsItem {
    var isToggled = Observable(Settings.shared.paymentsAuthentication.value)
    
    let title = L10n.Scene.Settings.Item.paymentsAuthentication
    
    init(authenticationViewModel: AuthenticationViewModel) {
        super.init()
        
        isToggled.observeNext { [weak self] isOn in
            if !isOn && Settings.shared.paymentsAuthentication.value {
                ModalPinViewController.authenticate(authenticationViewModel: authenticationViewModel) { [weak self] result in
                    switch result {
                    case .success:
                        Settings.shared.paymentsAuthentication.value = isOn

                    case .failure:
                        self?.isToggled.send(!isOn)
                    }
                }
            } else {
                Settings.shared.paymentsAuthentication.value = isOn
            }
        }
        .dispose(in: reactive.bag)
    }
    
    func didSelectItem(from fromViewController: UIViewController) {
    }
}
