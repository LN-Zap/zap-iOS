//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

public protocol ContainerViewController: class {
    var container: UIView? { get }
    var currentViewController: UIViewController? { get set }

    func setContainerContent(_ viewController: UIViewController)
}

public extension ContainerViewController where Self: UIViewController {
    func setContainerContent(_ viewController: UIViewController) {
        if self.currentViewController == nil {
            self.setInitialViewController(viewController)
        } else {
            self.switchToViewController(viewController)
        }
    }

    private func setInitialViewController(_ viewController: UIViewController) {
        guard let container = container else { return }

        addChild(viewController)
        viewController.view.frame = container.bounds
        container.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        currentViewController = viewController
    }

    private func switchToViewController(_ viewController: UIViewController, completion: (() -> Void)? = nil) {
        guard
            let currentViewController = currentViewController,
            let container = container
            else { return }

        currentViewController.willMove(toParent: nil)
        addChild(viewController)
        currentViewController.view.layer.zPosition = 1
        viewController.view.frame = container.bounds
        viewController.view.isUserInteractionEnabled = false

        transition(from: currentViewController,
                   to: viewController,
                   duration: 0.0,
                   options: [],
                   animations: { [currentViewController] in
                    currentViewController.view.alpha = 0
            }, completion: { [weak self] _ in
                guard let self = self else { return }
                currentViewController.view.removeFromSuperview()
                currentViewController.removeFromParent()
                viewController.didMove(toParent: self)
                self.currentViewController = viewController
                viewController.view.isUserInteractionEnabled = true
                completion?()
        })
    }
}
