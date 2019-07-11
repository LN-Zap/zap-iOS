//
//  Zap
//
//  Created by Otto Suess on 09.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Lightning
import Logger
import UIKit

private let itemWitdh: CGFloat = 140

final class ConfirmMnemonicViewController: UIViewController {
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var seedStackView: UIStackView!
    @IBOutlet private weak var buttonStackView: UIStackView!

    // swiftlint:disable implicitly_unwrapped_optional
    private var confirmViewModel: ConfirmMnemonicViewModel!
    private var connectWallet: ((WalletConfiguration) -> Void)!
    // swiftlint:enable implicitly_unwrapped_optional

    static func instantiate(confirmMnemonicViewModel: ConfirmMnemonicViewModel, connectWallet: @escaping (WalletConfiguration) -> Void) -> ConfirmMnemonicViewController {
        let viewController = StoryboardScene.CreateWallet.confirmMnemonicViewController.instantiate()
        viewController.confirmViewModel = confirmMnemonicViewModel
        viewController.connectWallet = connectWallet
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.Scene.ConfirmMnemonic.title

        view.backgroundColor = UIColor.Zap.background

        Style.Label.custom(color: .white).apply(to: descriptionLabel)

        guard let viewModel = confirmViewModel.wordList.first else { return }

        descriptionLabel.text = "Select word number \(viewModel.secretWord.index + 1)"

        for context in viewModel.context {
            let newContext: MnemonicWord
            if context == viewModel.secretWord {
                newContext = MnemonicWord(index: context.index, word: "")
            } else {
                newContext = context
            }

            let view = MnemonicWordView(mnemonic: newContext)
            view.heightAnchor.constraint(equalToConstant: 29).isActive = true
            seedStackView.addArrangedSubview(view)
        }

        for (index, answer) in viewModel.answers.enumerated() {
            if answer == viewModel.secretWord {
                Logger.info(index)
            }
            let button = UIButton(type: .system)
            button.setTitle(answer.word, for: .normal)
            Style.Button.background.apply(to: button)
            button.heightAnchor.constraint(equalToConstant: 56).isActive = true
            button.tag = answer.index
            button.addTarget(self, action: #selector(answerButtonTapped(sender:)), for: .touchUpInside)
            buttonStackView.addArrangedSubview(button)
        }
    }

    @IBAction private func answerButtonTapped(sender: UIButton) {
        guard let viewModel = confirmViewModel.wordList.first else { return }

        if sender.tag == viewModel.secretWord.index {
            print("🎉")
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}
