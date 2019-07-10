//
//  Library
//
//  Created by 0 on 08.07.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

final class OnboardingContainerViewController: UIViewController {
    @IBOutlet private weak var pageControl: UIPageControl!

    private var pages = [UIViewController]()

    private weak var pageViewController: OnboardingPageViewController?

    static func instantiate(pages: [UIViewController]) -> OnboardingContainerViewController {
        let viewController = StoryboardScene.Onboarding.onboardingContainerViewController.instantiate()
        viewController.pages = pages
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.Zap.background

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(_:)))
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
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
}

extension OnboardingContainerViewController: OnboardingPageViewControllerDelegate {
    func tutorialPageViewController(_ pageViewController: OnboardingPageViewController, didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }

    func tutorialPageViewController(_ pageViewController: OnboardingPageViewController, didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
}
