//
//  Zap
//
//  Created by Otto Suess on 24.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Lightning
import UIKit

final class RecoverWalletViewController: UIViewController {
    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var placeholderTextView: UITextView!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var doneButton: UIButton!

    // swiftlint:disable implicitly_unwrapped_optional
    private var recoverWalletViewModel: RecoverWalletViewModel!
    private var connectWallet: ((WalletConfiguration) -> Void)!
    // swiftlint:enable implicitly_unwrapped_optional

    static func instantiate(recoverWalletViewModel: RecoverWalletViewModel, connectWallet: @escaping (WalletConfiguration) -> Void) -> RecoverWalletViewController {
        let viewController = StoryboardScene.CreateWallet.recoverWalletViewController.instantiate()
        viewController.recoverWalletViewModel = recoverWalletViewModel
        viewController.connectWallet = connectWallet
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.Scene.RecoverWallet.title

        Style.Label.custom().apply(to: topLabel)
        Style.textView.apply(to: placeholderTextView, textView)
        Style.Button.custom().apply(to: doneButton)

        doneButton.setTitle(L10n.Scene.RecoverWallet.doneButton, for: .normal)
        topLabel.text = L10n.Scene.RecoverWallet.descriptionLabel
        topLabel.textColor = .white
        placeholderTextView.text = L10n.Scene.RecoverWallet.placeholder
        placeholderTextView.textColor = .darkGray
        placeholderTextView.backgroundColor = .clear

        textView.backgroundColor = .clear
        textView.text = nil
        textView.textColor = .white
        textView.delegate = self
        textView.becomeFirstResponder()
    }

    @IBAction private func recoverWallet(_ sender: Any) {
        guard let mnemonic = textView.text else { return }
        recoverWalletViewModel.recoverWallet(with: mnemonic) { [weak self] result in
            if let errorDescription = result.error?.localizedDescription {
                DispatchQueue.main.async {
                    Toast.presentError(errorDescription)
                }
            } else {
                DispatchQueue.main.async {
                    guard let configuration = self?.recoverWalletViewModel.configuration else { return }
                    self?.connectWallet?(configuration)
                }
            }
        }
    }
}

extension RecoverWalletViewController: UITextViewDelegate {
    func updateColors() {
        let cursorPosition = textView.selectedRange
        textView.attributedText = recoverWalletViewModel?.attributedString(from: textView.text)
        textView.selectedRange = cursorPosition
    }

    func textViewDidChange(_ textView: UITextView) {
        let isTextViewEmpty = textView.text == "" || textView.text == nil
        placeholderTextView.isHidden = !isTextViewEmpty
        updateColors()
    }
}
