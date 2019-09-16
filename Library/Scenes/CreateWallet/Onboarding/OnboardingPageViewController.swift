//
//  Library
//
//  Created by 0 on 08.07.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Logger
import UIKit

protocol OnboardingPageViewControllerDelegate: class {
    func tutorialPageViewController(_ pageViewController: OnboardingPageViewController, didUpdatePageCount count: Int)
    func tutorialPageViewController(_ pageViewController: OnboardingPageViewController, didUpdatePageIndex index: Int)
    func tutorialPageViewController(_ pageViewController: OnboardingPageViewController, didUpdateButtonTitle buttonTitle: String)
}

final class OnboardingPageViewController: UIPageViewController {
    private var paralaxStartOffset: CGFloat?
    private var paralaxStartViewController: OnboardingTextViewController?

    weak var containerDelegate: OnboardingPageViewControllerDelegate?

    var pages = [UIViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        view.backgroundColor = .clear

        if let firstViewController = pages.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }

        for view in self.view.subviews {
            if let view = view as? UIScrollView {
                view.delegate = self
                break
            }
        }

        updatePageIndex()
    }

    func presentNext() -> Bool {
        guard
            let currentViewController = viewControllers?.first,
            let nextViewController = pageViewController(self, viewControllerAfter: currentViewController)
            else { return false }
        setViewControllers([nextViewController], direction: .forward, animated: true) { [weak self] _ in
            self?.updatePageIndex()
        }

        if
            let nextViewController = nextViewController as? OnboardingTextViewController,
            let buttonTitle = nextViewController.buttonTitle {
            containerDelegate?.tutorialPageViewController(self, didUpdateButtonTitle: buttonTitle)
        }

        if let currentViewController = currentViewController as? OnboardingTextViewController {
            paralaxStartViewController = currentViewController
        }

        return true
    }
}

extension OnboardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        updatePageIndex()
        paralaxStartViewController = nil
    }

    private func updatePageIndex() {
        guard
            let currentViewController = viewControllers?.first,
            let index = pages.firstIndex(of: currentViewController)
            else { return }

        containerDelegate?.tutorialPageViewController(self, didUpdatePageIndex: index)
        containerDelegate?.tutorialPageViewController(self, didUpdatePageCount: pages.count)

        if
            let currentViewController = currentViewController as? OnboardingTextViewController,
            let buttonTitle = currentViewController.buttonTitle {
            containerDelegate?.tutorialPageViewController(self, didUpdateButtonTitle: buttonTitle)
        }
    }
}

extension OnboardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0, pages.count > previousIndex else {
            return nil
        }

        return pages[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = pages.count

        guard orderedViewControllersCount != nextIndex, orderedViewControllersCount > nextIndex else {
            return nil
        }

        return pages[nextIndex]
    }
}

extension OnboardingPageViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        paralaxStartOffset = scrollView.contentOffset.x
        if let currentViewController = viewControllers?.first as? OnboardingTextViewController {
            paralaxStartViewController = currentViewController
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let paralaxStartViewController = self.paralaxStartViewController else { return }

        let startOffset: CGFloat
        if let cachedOffset = self.paralaxStartOffset {
            startOffset = cachedOffset
        } else {
            startOffset = scrollView.contentOffset.x
            self.paralaxStartOffset = startOffset
        }

        let direction: Int
        if startOffset < scrollView.contentOffset.x {
            direction = 1
        } else if startOffset > scrollView.contentOffset.x {
            direction = -1
        } else {
            direction = 0
        }

        let positionFromStartOfCurrentPage = abs(startOffset - scrollView.contentOffset.x)
        let percent = positionFromStartOfCurrentPage / self.view.frame.width

        paralaxStartViewController.updatePageOffset(offset: percent * CGFloat(direction))

        if let currentIndex = pages.firstIndex(of: paralaxStartViewController),
            case let nextIndex = currentIndex + direction,
            nextIndex >= 0 && nextIndex < pages.count,
            let nextViewController = pages[nextIndex] as? OnboardingTextViewController {
            nextViewController.updatePageOffset(offset: (1 - percent) * CGFloat(direction) * -1)
        }
    }
}
