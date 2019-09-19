//
//  Zap
//
//  Created by Otto Suess on 24.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Lightning
import SwiftLnd
import UIKit

final class RecoverWalletViewController: UIViewController {
    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var placeholderTextView: UITextView!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var doneButton: UIButton!
    @IBOutlet private weak var wordCountLabel: UILabel!
    @IBOutlet private weak var selectBackupButton: UIButton!

    // swiftlint:disable implicitly_unwrapped_optional
    private var recoverWalletViewModel: RecoverWalletViewModel!
    private var connectWallet: ((LightningConnection) -> Void)!
    // swiftlint:enable implicitly_unwrapped_optional

    static func instantiate(recoverWalletViewModel: RecoverWalletViewModel, connectWallet: @escaping (LightningConnection) -> Void) -> RecoverWalletViewController {
        let viewController = StoryboardScene.CreateWallet.recoverWalletViewController.instantiate()
        viewController.recoverWalletViewModel = recoverWalletViewModel
        viewController.connectWallet = connectWallet
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.Scene.RecoverWallet.title
        view.backgroundColor = UIColor.Zap.background
        Style.Label.custom().apply(to: topLabel)
        Style.textView.apply(to: placeholderTextView, textView)
        Style.Button.custom().apply(to: doneButton)

        doneButton.setTitle(L10n.Scene.RecoverWallet.doneButton, for: .normal)
        doneButton.setTitleColor(UIColor.Zap.invisibleGray, for: .disabled)

        selectBackupButton.setTitle(L10n.Scene.RecoverWallet.selectChannelBackupButton, for: .normal)

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

        Style.Label.footnote.apply(to: wordCountLabel)
        wordCountLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)

        recoverWalletViewModel.mnemonic
            .map { "(\($0.count)/24)" }
            .bind(to: wordCountLabel.reactive.text)
            .dispose(in: reactive.bag)

        recoverWalletViewModel.mnemonic
            .map { $0.count == 24 }
            .bind(to: doneButton.reactive.isEnabled)
            .dispose(in: reactive.bag)
    }

    @IBAction private func recoverWallet(_ sender: Any) {
        guard let mnemonic = textView.text else { return }
        recoverWalletViewModel.recoverWallet(with: mnemonic) { [weak self] result in
            if case .failure(let error) = result {
                DispatchQueue.main.async {
                    Toast.presentError(error.localizedDescription)
                }
            } else {
                DispatchQueue.main.async {
                    guard let configuration = self?.recoverWalletViewModel.connection else { return }
                    self?.connectWallet?(configuration)
                }
            }
        }
    }

    @IBAction private func selectBackup(_ sender: Any) {
        #if targetEnvironment(simulator)
        // UIDocumentPickerViewController is broken on simulator
        let alertController = UIAlertController(title: "Debug", message: "Paste base64 file data.", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "base64"
        }
        let confirmAction = UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
            guard let textField = alertController.textFields?.first else { return }

            if let text = textField.text, let data = Data(base64Encoded: text) {
                self?.recoverWalletViewModel.staticChannelBackup = ChannelBackup(data: data)
                self?.selectBackupButton.setTitle("✅", for: .normal)
            } else {
                self?.selectBackupButton.setTitle("⚠️", for: .normal)
            }
        }
        alertController.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
        #else
        let viewController = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
        viewController.delegate = self
        present(viewController, animated: false)
        #endif
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

extension RecoverWalletViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard
            let url = urls.first,
            let fileData = try? Data(contentsOf: url) else { return }

        recoverWalletViewModel.staticChannelBackup = ChannelBackup(data: fileData)
        selectBackupButton.setTitle(url.lastPathComponent, for: .normal)
    }
}
