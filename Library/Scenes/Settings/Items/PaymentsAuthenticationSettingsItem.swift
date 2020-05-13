//
//  Library
//
//  Created by Ivan Kuznetsov on 11.05.2020.
//  Copyright © 2020 Zap. All rights reserved.
//

import Bond
import SwiftLnd
import UIKit

final class PaymentsAuthenticationSettingsItem: NSObject, ToggleSettingsItem {
    var isToggled = Observable(Settings.shared.paymentsAuthentication.value)
    
    let title = L10n.Scene.Settings.Item.paymentsAuthentication

    private let authenticationViewModel: AuthenticationViewModel
    var fakeAuthViewController = UIViewController()

    init(authenticationViewModel: AuthenticationViewModel) {
        self.authenticationViewModel = authenticationViewModel

        super.init()
        
        isToggled.observeNext { [weak self] isOn in
            if !isOn && Settings.shared.paymentsAuthentication.value {
                self?.authenticate { [weak self] result in
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

    private func authenticate(completion: @escaping (Result<Success, AuthenticationError>) -> Void) {
        if BiometricAuthentication.type == .none {
            ModalPinViewController.authenticate(authenticationViewModel: authenticationViewModel) { completion($0) }
        } else {
            BiometricAuthentication.authenticate(viewController: fakeAuthViewController) { [authenticationViewModel] result in
                if case .failure(let error) = result,
                    error == AuthenticationError.useFallback {
                    ModalPinViewController.authenticate(authenticationViewModel: authenticationViewModel) { completion($0) }
                } else {
                    completion(result)
                }
            }
        }
    }
}
