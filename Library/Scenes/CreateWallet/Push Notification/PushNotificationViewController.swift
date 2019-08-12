//
//  Library
//
//  Created by 0 on 19.07.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

final class PushNotificationViewController: UIViewController {
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var confirmButton: UIButton!
    @IBOutlet private weak var skipButton: UIButton!

    private var completion: (() -> Void)?

    static func instantiate(completion: @escaping (() -> Void)) -> PushNotificationViewController {
        let viewController = StoryboardScene.PushNotification.pushNotificationViewController.instantiate()
        viewController.completion = completion
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true

        view.backgroundColor = UIColor.Zap.background
        separatorView.backgroundColor = UIColor.Zap.lightningOrange

        Style.Button.background.apply(to: confirmButton)
        Style.Label.body.apply(to: messageLabel)
        messageLabel.textColor = UIColor.Zap.gray

        Style.Label.title.apply(to: headlineLabel)
        skipButton.setTitleColor(UIColor.Zap.gray, for: .normal)

        let fontSize: CGFloat
        switch UIScreen.main.sizeType {
        case .small:
            fontSize = 25
        case .big:
            fontSize = 40
        }
        headlineLabel.font = headlineLabel.font.withSize(fontSize)

        headlineLabel.text = L10n.Scene.PushNotification.headline
        messageLabel.text = L10n.Scene.PushNotification.message
        confirmButton.setTitle(L10n.Scene.PushNotification.confirmButtonTitle, for: .normal)
        skipButton.setTitle(L10n.Scene.PushNotification.skipButtonTitle, for: .normal)
    }

    @IBAction private func confirm(_ sender: Any) {
        guard let completion = completion else { return }
        NotificationScheduler.requestAuthorization {
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    @IBAction private func skip(_ sender: Any) {
        completion?()
    }
}
