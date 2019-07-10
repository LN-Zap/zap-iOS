//
//  Library
//
//  Created by 0 on 08.07.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import UIKit

class OnboardingTextViewController: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var actionButton: UIButton!

    private var titleText: String?
    private var messageText: String?
    private var image: UIImage?
    private var action: (() -> Void)?

    static func instantiate(title: String, message: String, image: UIImage?, action: (() -> Void)? = nil) -> OnboardingTextViewController {
        let viewController = StoryboardScene.Onboarding.onboardingTextViewController.instantiate()

        viewController.titleText = title
        viewController.messageText = message
        viewController.image = image
        viewController.action = action

        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        separatorView.backgroundColor = UIColor.Zap.lightningOrange

        titleLabel.text = titleText
        messageLabel.text = messageText
        imageView.image = image

        messageLabel.textColor = UIColor.Zap.gray

        if action == nil {
            actionButton.isHidden = true
        } else {
            Style.Button.background.apply(to: actionButton)
            actionButton.setTitle("Generate Seed", for: .normal)
        }
    }

    @IBAction private func actionButtonTapped(_ sender: Any) {
        action?()
    }
}
