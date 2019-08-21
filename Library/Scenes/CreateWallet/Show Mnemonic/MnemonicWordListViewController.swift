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
            stackView.addArrangedSubview(MnemonicWordView(mnemonic: mnemonic, highlighted: mnemonic.index % 2 == 0))
        }
    }
}
