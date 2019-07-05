//
//  Zap
//
//  Created by Otto Suess on 09.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import SafariServices
import UIKit

final class SelectWalletCreationMethodViewController: UIViewController {
    private var createButtonTapped: (() -> Void)?
    private var recoverButtonTapped: (() -> Void)?
    private var connectButtonTapped: (() -> Void)?

    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var createButton: UIButton!
    @IBOutlet private weak var recoverButton: UIButton!
    @IBOutlet private weak var connectButton: UIButton!

    static func instantiate(createButtonTapped: @escaping () -> Void, recoverButtonTapped: @escaping () -> Void, connectButtonTapped: @escaping () -> Void) -> SelectWalletCreationMethodViewController {
        let setupWalletViewController = StoryboardScene.CreateWallet.selectWalletCreationMethodViewController.instantiate()
        setupWalletViewController.createButtonTapped = createButtonTapped
        setupWalletViewController.recoverButtonTapped = recoverButtonTapped
        setupWalletViewController.connectButtonTapped = connectButtonTapped
        return setupWalletViewController
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
        navigationController?.navigationBar.barTintColor = .clear
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.navigationBar.barTintColor = UIColor.Zap.deepSeaBlue
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        createButton.setTitle(L10n.Scene.SelectWalletConnection.Create.title, for: .normal)
        recoverButton.setTitle(L10n.Scene.SelectWalletConnection.Recover.title, for: .normal)
        connectButton.setTitle(L10n.Scene.SelectWalletConnection.Connect.title, for: .normal)
        recoverButton.setTitleColor(UIColor.Zap.invisibleGray, for: .normal)
        connectButton.setTitleColor(UIColor.Zap.invisibleGray, for: .normal)

        titleLabel.text = L10n.Scene.SelectWalletConnection.message

        view.backgroundColor = UIColor.Zap.background
        separatorView.backgroundColor = UIColor.Zap.lightningOrange

        Style.Button.background.apply(to: createButton)
    }

    @IBAction private func createWallet() {
        createButtonTapped?()
    }

    @IBAction private func recoverWallet() {
        recoverButtonTapped?()
    }

    @IBAction private func connectNode() {
        connectButtonTapped?()
    }
}
