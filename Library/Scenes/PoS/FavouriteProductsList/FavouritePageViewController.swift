//
//  Library
//
//  Created by Otto Suess on 28.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class FavouritePageViewController: UIPageViewController {

    private var orderedViewControllers: [UIViewController]?

    // swiftlint:disable implicitly_unwrapped_optional
    var productsViewModel: ProductsViewModel!
    var shoppingCartViewModel: ShoppingCartViewModel!
    // swiftlint:enable implicitly_unwrapped_optional
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.Zap.background
        
        dataSource = self
        
        orderedViewControllers = [
            UIStoryboard.instantiateFavouritePageContentViewController(productsViewModel: productsViewModel, shoppingCartViewModel: shoppingCartViewModel, pageIndex: 0),
            UIStoryboard.instantiateFavouritePageContentViewController(productsViewModel: productsViewModel, shoppingCartViewModel: shoppingCartViewModel, pageIndex: 1)
        ]
        
        if let firstViewController = orderedViewControllers?.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
}

extension FavouritePageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard
            let orderedViewControllers = orderedViewControllers,
            let viewControllerIndex = orderedViewControllers.index(of: viewController)
            else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else { return nil }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard
            let orderedViewControllers = orderedViewControllers,
            let viewControllerIndex = orderedViewControllers.index(of: viewController)
            else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < orderedViewControllers.count else { return nil }
        
        return orderedViewControllers[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers?.count ?? 0
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard
            let currentViewController = viewControllers?.first,
            let orderedViewControllers = orderedViewControllers,
            let viewControllerIndex = orderedViewControllers.index(of: currentViewController)
            else { return 0 }

        return viewControllerIndex
    }
}
