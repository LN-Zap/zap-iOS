//
//  Zap
//
//  Created by Otto Suess on 24.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static func instantiateRecoverWalletViewController(recoverWalletViewModel: RecoverWalletViewModel, presentSetupPin: @escaping () -> Void) -> RecoverWalletViewController {
        let viewController = Storyboard.createWallet.instantiate(viewController: RecoverWalletViewController.self)
        viewController.recoverWalletViewModel = recoverWalletViewModel
        viewController.presentSetupPin = presentSetupPin
        return viewController
    }
}

final class RecoverWalletViewController: UIViewController {

    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var placeholderTextView: UITextView!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var doneButton: UIButton!
    
    fileprivate var recoverWalletViewModel: RecoverWalletViewModel?
    fileprivate var presentSetupPin: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "scene.recover_wallet.title".localized
        
        Style.Label.custom().apply(to: topLabel)
        Style.textView.apply(to: placeholderTextView, textView)
        Style.button().apply(to: doneButton)
        
        doneButton.setTitle("scene.recover_wallet.done_button".localized, for: .normal)
        topLabel.text = "scene.recover_wallet.description_label".localized
        topLabel.textColor = .white
        placeholderTextView.text = "scene.recover_wallet.placeholder".localized
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
        recoverWalletViewModel?.recoverWallet(with: mnemonic) { [weak self] result in
            if let errorDescription = result.error?.localizedDescription {
                DispatchQueue.main.async {
                    let toast = Toast(message: errorDescription, style: .error)
                    self?.presentToast(toast, animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    self?.presentSetupPin?()
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
