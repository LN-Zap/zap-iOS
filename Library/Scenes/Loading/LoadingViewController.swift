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
    @IBOutlet private weak var tabBar: UITabBar!
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

        tabBar.barTintColor = UIColor.Zap.seaBlue
        tabBar.isTranslucent = false
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()

        tabBar.items = [Tab.wallet, Tab.history, Tab.settings].map {
            UITabBarItem(title: $0.title, image: $0.image, selectedImage: $0.image)
        }
        tabBar.isUserInteractionEnabled = false

        sendButtonBackground.backgroundColor = UIColor.Zap.seaBlue
        receiveButtonBackground.backgroundColor = UIColor.Zap.seaBlue

        Style.Button.custom().apply(to: sendButton, requestButton)

        buttonContainerView.layer.cornerRadius = 20
        buttonContainerView.clipsToBounds = true
        buttonContainerView.backgroundColor = UIColor.Zap.deepSeaBlue

        UIView.performWithoutAnimation {
            sendButton.setTitle(L10n.Scene.Main.sendButton, for: .normal)
            sendButton.layoutIfNeeded()
            requestButton.setTitle(L10n.Scene.Main.receiveButton, for: .normal)
            requestButton.layoutIfNeeded()
        }

        sendButton.setTitleColor(UIColor.Zap.gray, for: .disabled)
        requestButton.setTitleColor(UIColor.Zap.gray, for: .disabled)

        sendButton.isEnabled = false
        requestButton.isEnabled = false
    }
}
