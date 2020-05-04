//
//  Zap
//
//  Created by Otto Suess on 19.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Foundation

final class MnemonicViewController: UIViewController {
    @IBOutlet private weak var doneButton: UIButton!
    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    private weak var pageViewController: MnemonicPageViewController?

    private var mnemonicViewModel: MnemonicViewModel?
    private var presentConfirmMnemonic: (() -> Void)?

    static func instantiate(mnemonicViewModel: MnemonicViewModel, presentConfirmMnemonic: @escaping () -> Void) -> MnemonicViewController {
        let viewController = StoryboardScene.CreateWallet.mnemonicViewController.instantiate()
        viewController.mnemonicViewModel = mnemonicViewModel
        viewController.presentConfirmMnemonic = presentConfirmMnemonic
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.Scene.CreateWallet.title
        view.backgroundColor = UIColor.Zap.deepSeaBlue
        activityIndicator.startAnimating()

        Style.Button.background.apply(to: doneButton)
        Style.Label.custom().apply(to: topLabel)
        topLabel.textColor = .white
        topLabel.text = L10n.Scene.CreateWallet.descriptionLabel

        doneButton.setTitle(L10n.Scene.CreateWallet.nextButton, for: .normal)

        mnemonicViewModel?.pageWords
            .map { $0 != nil }
            .receive(on: DispatchQueue.main)
            .bind(to: activityIndicator.reactive.isHidden)
            .dispose(in: reactive.bag)
    }

    @IBAction private func nextButtonTapped(_ sender: Any) {
        if pageViewController?.isLastViewController == true {
            presentConfirmMnemonic?()
        } else {
            pageViewController?.skipToNextViewController()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? MnemonicPageViewController {
            destination.mnemonicViewModel = mnemonicViewModel
            pageViewController = destination
        }
    }
}
