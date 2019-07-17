//
//  Library
//
//  Created by 0 on 08.07.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

final class OnboardingContainerViewController: UIViewController {
    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet private weak var actionButton: UIButton!

    private lazy var pages: [UIViewController] = { [
        OnboardingTextViewController.instantiate(title: L10n.Scene.Onboarding.Page1.title, message: L10n.Scene.Onboarding.Page1.message, image: Emoji.image(emoji: "🤴"), buttonTitle: L10n.Scene.Onboarding.Page1.buttonTitle),
        OnboardingTextViewController.instantiate(title: L10n.Scene.Onboarding.Page2.title, message: L10n.Scene.Onboarding.Page2.message, image: Emoji.image(emoji: "✍️"), buttonTitle: L10n.Scene.Onboarding.Page2.buttonTitle),
        OnboardingTextViewController.instantiate(title: L10n.Scene.Onboarding.Page3.title, message: L10n.Scene.Onboarding.Page3.message, image: Emoji.image(emoji: "🗝"), buttonTitle: L10n.Scene.Onboarding.Page3.buttonTitle)
    ] }()

    private var completion: (() -> Void)?

    private weak var pageViewController: OnboardingPageViewController?

    static func instantiate(completion: @escaping () -> Void) -> OnboardingContainerViewController {
        let viewController = StoryboardScene.Onboarding.onboardingContainerViewController.instantiate()
        viewController.completion = completion
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.Zap.background

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(_:)))
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)

        Style.Button.background.apply(to: actionButton)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pageViewController = segue.destination as? OnboardingPageViewController {
            pageViewController.containerDelegate = self
            pageViewController.pages = pages
            self.pageViewController = pageViewController
        }
    }

    @IBAction private func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func actionButtonTapped(_ sender: Any) {
        if pageViewController?.presentNext() == false {
            completion?()
        }
    }
}

extension OnboardingContainerViewController: OnboardingPageViewControllerDelegate {
    func tutorialPageViewController(_ pageViewController: OnboardingPageViewController, didUpdateButtonTitle buttonTitle: String) {
        actionButton.setTitle(buttonTitle, for: .normal)
    }

    func tutorialPageViewController(_ pageViewController: OnboardingPageViewController, didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }

    func tutorialPageViewController(_ pageViewController: OnboardingPageViewController, didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
}
