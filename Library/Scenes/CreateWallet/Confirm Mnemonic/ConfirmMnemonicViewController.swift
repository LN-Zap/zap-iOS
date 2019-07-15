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

protocol ConfirmMnemonicViewControllerDelegate: class {
    func didSelectWrongWord()
    func didSelectCorrectWord(on viewController: ConfirmMnemonicViewController)
}

final class ConfirmMnemonicViewController: UIViewController {
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var seedStackView: UIStackView!
    @IBOutlet private weak var buttonStackView: UIStackView!

    weak var delegate: ConfirmMnemonicViewControllerDelegate?

    // swiftlint:disable implicitly_unwrapped_optional
    private var confirmViewModel: ConfirmWordViewModel!
    // swiftlint:enable implicitly_unwrapped_optional

    static func instantiate(confirmWordViewModel: ConfirmWordViewModel, delegate: ConfirmMnemonicViewControllerDelegate) -> ConfirmMnemonicViewController {
        let viewController = StoryboardScene.ConfirmMnemonic.confirmMnemonicViewController.instantiate()
        viewController.confirmViewModel = confirmWordViewModel
        viewController.delegate = delegate
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.Zap.background

        Style.Label.custom(color: .white).apply(to: descriptionLabel)

        descriptionLabel.text = L10n.Scene.ConfirmMnemonic.headline(confirmViewModel.secretWord.index + 1)

        for context in confirmViewModel.context {
            let newContext: MnemonicWord
            if context == confirmViewModel.secretWord {
                newContext = MnemonicWord(index: context.index, word: "")
            } else {
                newContext = context
            }

            let view = MnemonicWordView(mnemonic: newContext)
            view.heightAnchor.constraint(equalToConstant: 29).isActive = true
            seedStackView.addArrangedSubview(view)
        }

        for (index, answer) in confirmViewModel.answers.enumerated() {
            if answer == confirmViewModel.secretWord {
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
        if sender.tag == confirmViewModel.secretWord.index {
            delegate?.didSelectCorrectWord(on: self)
        } else {
            delegate?.didSelectWrongWord()
        }
    }
}
