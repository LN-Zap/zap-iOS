//
//  ZapShared
//
//  Created by Otto Suess on 18.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import Lightning

final class ChangePinSettingsItem: SettingsItem {
    let title = L10n.Scene.Settings.Item.changePin
    
    private let authenticationViewModel: AuthenticationViewModel
    private weak var setupPinViewController: SetupPinViewController?
    
    init(authenticationViewModel: AuthenticationViewModel) {
        self.authenticationViewModel = authenticationViewModel
    }
    
    func didSelectItem(from fromViewController: UIViewController) {
        ModalPinViewController.authenticate(authenticationViewModel: authenticationViewModel) { [weak self, authenticationViewModel] result in
            switch result {
            case .success:
                let viewModel = SetupPinViewModel(authenticationViewModel: authenticationViewModel)
                let setupPinViewController = SetupPinViewController.instantiate(setupPinViewModel: viewModel) { [weak self] in
                    self?.setupPinViewController?.dismiss(animated: true, completion: nil)
                }
                self?.setupPinViewController = setupPinViewController
                fromViewController.present(setupPinViewController, animated: true, completion: nil)
            case .failure:
                return
            }
        }
    }
}
