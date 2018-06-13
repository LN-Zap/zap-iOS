//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

protocol ContainerViewController: class {
    var container: UIView? { get }
    var currentViewController: UIViewController? { get set }
    
    func setContainerContent(_ viewController: UIViewController)
}

extension ContainerViewController where Self: UIViewController {
    
    func setContainerContent(_ viewController: UIViewController) {
        if currentViewController == nil {
            setInitialViewController(viewController)
        } else {
            switchToViewController(viewController)
        }
    }
    
    private func setInitialViewController(_ viewController: UIViewController) {
        guard let container = container else { return }
        
        addChildViewController(viewController)
        viewController.view.frame = container.bounds
        container.addSubview(viewController.view)
        viewController.didMove(toParentViewController: self)
        self.currentViewController = viewController
    }
    
    private func switchToViewController(_ viewController: UIViewController, completion: (() -> Void)? = nil) {
        guard
            let currentViewController = currentViewController,
            let container = container
            else { return }
        
        currentViewController.willMove(toParentViewController: nil)
        addChildViewController(viewController)
        currentViewController.view.layer.zPosition = 1
        viewController.view.frame = container.bounds
        viewController.view.isUserInteractionEnabled = false
        
        transition(from: currentViewController,
                   to: viewController,
                   duration: 0.3,
                   options: [],
                   animations: { [currentViewController] in
                    currentViewController.view.alpha = 0
            }, completion: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.currentViewController?.removeFromParentViewController()
                viewController.didMove(toParentViewController: self)
                strongSelf.currentViewController = viewController
                viewController.view.isUserInteractionEnabled = true
                completion?()
        })
    }
}
