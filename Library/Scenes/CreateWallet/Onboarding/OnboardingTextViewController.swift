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

    private var titleText: String! // swiftlint:disable:this implicitly_unwrapped_optional
    private var messageText: String?
    private var image: UIImage?
    public private(set) var buttonTitle: String?

    static func instantiate(title: String, message: String, image: UIImage?, buttonTitle: String) -> OnboardingTextViewController {
        let viewController = StoryboardScene.Onboarding.onboardingTextViewController.instantiate()

        viewController.titleText = title
        viewController.messageText = message
        viewController.image = image
        viewController.buttonTitle = buttonTitle

        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        separatorView.backgroundColor = UIColor.Zap.lightningOrange

        let fontSize: CGFloat
        switch UIScreen.main.sizeType {
        case .small:
            fontSize = 25
        case .big:
            fontSize = 40
        }

        titleLabel.setMarkdown(titleText, fontSize: fontSize, weight: .light, boldWeight: .medium)
        messageLabel.text = messageText
        imageView.image = image

        messageLabel.textColor = UIColor.Zap.gray
    }
}
