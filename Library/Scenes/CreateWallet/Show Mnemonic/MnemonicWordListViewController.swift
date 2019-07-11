//
//  Zap
//
//  Created by Otto Suess on 16.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class MnemonicWordListViewController: UIViewController {
    @IBOutlet private weak var stackView: UIStackView!

    private var mnemonicWords: [MnemonicWord]?

    static func instantiate(with mnemonicWords: [MnemonicWord]) -> MnemonicWordListViewController {
        let viewController = StoryboardScene.CreateWallet.mnemonicWordListViewController.instantiate()
        viewController.mnemonicWords = mnemonicWords
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        guard let mnemonicWords = mnemonicWords else { return }

        for mnemonic in mnemonicWords {
            let backgroundView = UIView()

            let indexLabel = UILabel(frame: CGRect.zero)
            if mnemonic.index < 9 {
                indexLabel.text = "0\(mnemonic.index + 1)"
            } else {
                indexLabel.text = "\(mnemonic.index + 1)"
            }

            let wordLabel = UILabel(frame: CGRect.zero)
            wordLabel.text = "\(mnemonic.word)"
            Style.Label.body.apply(to: wordLabel)
            indexLabel.textColor = UIColor.Zap.gray
            indexLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .light)

            indexLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 999), for: .horizontal)

            let horizontalStackView = UIStackView(arrangedSubviews: [
                indexLabel,
                wordLabel
            ])
            horizontalStackView.axis = .horizontal
            horizontalStackView.spacing = 20

            if mnemonic.index % 2 == 0 {
                backgroundView.backgroundColor = UIColor.Zap.seaBlue
            }

            backgroundView.addAutolayoutSubview(horizontalStackView)

            NSLayoutConstraint.activate([
                horizontalStackView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
                horizontalStackView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
                horizontalStackView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 20),
                horizontalStackView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: 20)
            ])

            stackView.addArrangedSubview(backgroundView)
        }
    }
}
