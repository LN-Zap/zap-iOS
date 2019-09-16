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
    @IBOutlet private weak var imageContainer: UIView!

    // swiftlint:disable implicitly_unwrapped_optional
    private var titleText: String!
    private var messageText: String!
    private var imageLayer: [UIImage]!
    public private(set) var buttonTitle: String!
    // swiftlint:enable implicitly_unwrapped_optional

    var imageViews: [UIImageView]?

    static func instantiate(title: String, message: String, imageLayer: [UIImage], buttonTitle: String) -> OnboardingTextViewController {
        let viewController = StoryboardScene.Onboarding.onboardingTextViewController.instantiate()

        viewController.titleText = title
        viewController.messageText = message
        viewController.imageLayer = imageLayer
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

        let imageViews = imageLayer.map { (image: UIImage) -> UIImageView in
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            return imageView
        }
        self.imageViews = imageViews

        for imageView in imageViews {
            imageContainer.addAutolayoutSubview(imageView)

            imageView.constrainCenter(to: imageContainer)
            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(greaterThanOrEqualTo: imageContainer.leadingAnchor, constant: 20),
                imageView.topAnchor.constraint(greaterThanOrEqualTo: imageContainer.topAnchor, constant: 20)
            ])
        }

        messageLabel.textColor = UIColor.Zap.gray
    }

    func updatePageOffset(offset: CGFloat) {
        guard let imageViews = imageViews else { return }
        for (index, imageView) in imageViews.enumerated() {
            let normalizedIndex: CGFloat
            if index == 3 { // this is a super lazy hack. the image with the onboarding is the only one with 4 layers, and the top layer should stick to the bottom layer 🤷🏻‍♂️
                normalizedIndex = 0
            } else {
                normalizedIndex = CGFloat(index) / min(CGFloat(imageViews.count), 3)
            }
            imageView.transform = CGAffineTransform(translationX: normalizedIndex * offset * -200, y: 0)

        }
    }
}
