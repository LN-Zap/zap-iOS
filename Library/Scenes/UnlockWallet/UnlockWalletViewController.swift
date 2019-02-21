//
//  Library
//
//  Created by Otto Suess on 19.02.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning
import Logger
import ReactiveKit

final class UnlockWalletViewController: UIViewController, KeyboardAdjustable {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    
    // swiftlint:disable implicitly_unwrapped_optional
    private var unlockWalletViewModel: UnlockWalletViewModel!
    private weak var disconnectWalletDelegate: DisconnectWalletDelegate!
    // swiftlint:enable implicitly_unwrapped_optional
    
    static func instantiate(unlockWalletViewModel: UnlockWalletViewModel, disconnectWalletDelegate: DisconnectWalletDelegate) -> UnlockWalletViewController {
        let viewController = StoryboardScene.UnlockWallet.unlockWalletViewController.instantiate()
        viewController.unlockWalletViewModel = unlockWalletViewModel
        viewController.disconnectWalletDelegate = disconnectWalletDelegate
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.Zap.background
        
        title = L10n.Scene.Unlock.title
        titleLabel.text = L10n.Scene.Unlock.titleLabel(unlockWalletViewModel.nodeAlias)
        
        textField.attributedPlaceholder = NSAttributedString(
            string: L10n.Scene.Unlock.passwordPlaceholder,
            attributes: [.foregroundColor: UIColor.Zap.gray]
        )
        submitButton.setTitle(L10n.Scene.Unlock.unlockButton, for: .normal)
        
        Style.Label.headline.apply(to: titleLabel)
        Style.Button.background.apply(to: submitButton)
        Style.textField(color: .white).apply(to: textField)
        
        textField.becomeFirstResponder()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        
        textField.textContentType = .password
        
        unlockWalletViewModel.isUnlocking
            .map { !$0 }
            .bind(to: activityIndicator.reactive.isHidden)
            .dispose(in: reactive.bag)
        
        combineLatest(textField.reactive.text, unlockWalletViewModel.isUnlocking)
            .map { ($0?.count ?? 0) > 7 && !$1 }
            .bind(to: submitButton.reactive.isEnabled)
            .dispose(in: reactive.bag)
        
        setupKeyboardNotifications(constraint: bottomConstraint)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textField.resignFirstResponder()
    }
    
    @IBAction private func submitButtonTapped(_ sender: Any) {
        guard let password = textField.text else { return }
        unlockWalletViewModel.unlock(password: password)
    }
    
    @objc private func cancel() {
        disconnectWalletDelegate.disconnect()
    }
}
