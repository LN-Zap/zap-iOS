//
//  Library
//
//  Created by 0 on 25.10.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

final class WalletPageViewController: UIPageViewController {
    
    // swiftlint:disable implicitly_unwrapped_optional
    private var walletViewController: WalletViewController!
    private var nodeViewController: (() -> UIViewController)!
    private var historyViewController: (() -> UIViewController)!
    // swiftlint:enable implicitly_unwrapped_optional

    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [:])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func instantiate(walletViewController: WalletViewController, nodeViewController: @escaping () -> UIViewController, historyViewController: @escaping () -> UIViewController) -> WalletPageViewController {
        let viewController = WalletPageViewController()
        
        viewController.walletViewController = walletViewController
        viewController.nodeViewController = nodeViewController
        viewController.historyViewController = historyViewController
        
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViewControllers([walletViewController], direction: .forward, animated: false)
        
        dataSource = self
        view.backgroundColor = UIColor.Zap.background
    }
    
    func presentNode() {
        setViewControllers([nodeViewController()], direction: .reverse, animated: true, completion: nil)
    }
    
    func presentHistory() {
        setViewControllers([historyViewController()], direction: .forward, animated: true, completion: nil)
    }
    
    func presentWallet() {
        if let currentViewController = viewControllers?.first as? UINavigationController {
            let direction: UIPageViewController.NavigationDirection
            if currentViewController.viewControllers.first is NodeViewController {
                direction = .forward
            } else {
                direction = .reverse
            }
            setViewControllers([walletViewController], direction: direction, animated: true, completion: nil)
        }
    }
}

extension WalletPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentViewController = viewControllers?.first else { return nil }
        
        if currentViewController == walletViewController {
            return nodeViewController()
        } else if let currentViewController = currentViewController as? UINavigationController {
            if currentViewController.viewControllers.first is HistoryViewController {
                return walletViewController
            }
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentViewController = viewControllers?.first else { return nil }
        
        if currentViewController == walletViewController {
            return historyViewController()
        } else if let currentViewController = currentViewController as? UINavigationController {
            if currentViewController.viewControllers.first is NodeViewController {
                return walletViewController
            }
        }
        
        return nil
    }
}
