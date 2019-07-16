//
//  Library
//
//  Created by 0 on 12.07.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

final class ConfirmMnemonicPageViewController: UIPageViewController {
    // swiftlint:disable implicitly_unwrapped_optional
    private var confirmViewModel: ConfirmMnemonicViewModel!
    private var connectWallet: ((WalletConfiguration) -> Void)!
    // swiftlint:enable implicitly_unwrapped_optional

    var pages = [UIViewController]()

    static func instantiate(confirmMnemonicViewModel: ConfirmMnemonicViewModel, connectWallet: @escaping (WalletConfiguration) -> Void) -> ConfirmMnemonicPageViewController {
        let viewController = StoryboardScene.ConfirmMnemonic.confirmMnemonicPageViewController.instantiate()
        viewController.confirmViewModel = confirmMnemonicViewModel
        viewController.connectWallet = connectWallet
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.Scene.ConfirmMnemonic.title
        view.backgroundColor = UIColor.Zap.background

        dataSource = self

        pages = confirmViewModel.wordViewModels.map {
            ConfirmMnemonicViewController.instantiate(confirmWordViewModel: $0, delegate: self)
        }
        setViewControllers([pages[0]], direction: .forward, animated: false, completion: nil)

        // remove swipe gesture
        for view in view.subviews {
            if let subView = view as? UIScrollView {
                subView.isScrollEnabled = false
            }
        }
    }
}

extension ConfirmMnemonicPageViewController: UIPageViewControllerDataSource {
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let currentViewController = viewControllers?.first else { return 0 }
        return pages.firstIndex(of: currentViewController) ?? 0
    }

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

extension ConfirmMnemonicPageViewController: ConfirmMnemonicViewControllerDelegate {
    func didSelectWrongWord() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        navigationController?.popViewController(animated: true)
    }

    func didSelectCorrectWord(on viewController: ConfirmMnemonicViewController) {
        guard let index = pages.firstIndex(of: viewController) else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        if Int(index) + 1 >= pages.count {
            createNewWallet()
        } else {
            setViewControllers([pages[index + 1]], direction: .forward, animated: true, completion: nil)
        }
    }

    private func createNewWallet() {
        confirmViewModel.createWallet { [weak self] in
            guard let self = self else { return }
            switch $0 {
            case .success:
                DispatchQueue.main.async {
                    self.connectWallet?(self.confirmViewModel.configuration)
                    self.dismiss(animated: true, completion: nil)
                }
            case .failure(let error):
                Toast.presentError(error.localizedDescription)
            }
        }
    }
}
