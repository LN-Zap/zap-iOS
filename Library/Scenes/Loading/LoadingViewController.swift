//
//  Zap
//
//  Created by Otto Suess on 13.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Lightning
import SwiftLnd
import UIKit

final class LoadingViewController: UIViewController {
    @IBOutlet private weak var buttonContainerView: UIView!
    @IBOutlet private weak var sendButtonBackground: UIView!
    @IBOutlet private weak var receiveButtonBackground: UIView!
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var requestButton: UIButton!

    static func instantiate() -> LoadingViewController {
        return StoryboardScene.Loading.initialScene.instantiate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.Zap.background

        sendButtonBackground.backgroundColor = UIColor.Zap.seaBlue
        receiveButtonBackground.backgroundColor = UIColor.Zap.seaBlue

        Style.Button.custom().apply(to: sendButton, requestButton)

        buttonContainerView.layer.cornerRadius = Constants.buttonCornerRadius
        buttonContainerView.clipsToBounds = true
        buttonContainerView.backgroundColor = UIColor.Zap.deepSeaBlue

        UIView.performWithoutAnimation {
            sendButton.setTitle(L10n.Scene.Main.sendButton, for: .normal)
            sendButton.layoutIfNeeded()
            requestButton.setTitle(L10n.Scene.Main.receiveButton, for: .normal)
            requestButton.layoutIfNeeded()
        }

        sendButton.setTitleColor(UIColor.Zap.invisibleGray, for: .disabled)
        requestButton.setTitleColor(UIColor.Zap.invisibleGray, for: .disabled)

        sendButton.isEnabled = false
        requestButton.isEnabled = false
    }
}
