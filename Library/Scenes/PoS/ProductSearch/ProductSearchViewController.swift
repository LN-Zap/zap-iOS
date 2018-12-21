//
//  Library
//
//  Created by Otto Suess on 21.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

extension UIStoryboard {
    static func instantiateProductSearchViewController(shoppingCartViewModel: ShoppingCartViewModel) -> ZapNavigationController {
        let productSearchViewController = StoryboardScene.PoS.productSearchViewController.instantiate()
        
        productSearchViewController.shoppingCartViewModel = shoppingCartViewModel
        
        let navigationController = ZapNavigationController(rootViewController: productSearchViewController)

        navigationController.tabBarItem.image = Asset.tabbarWallet.image
        navigationController.tabBarItem.title = "Search"

        return navigationController
    }
}

final class ProductSearchViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    fileprivate var shoppingCartViewModel: ShoppingCartViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = "Search"
        
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.backgroundColor = UIColor.Zap.background
        view.backgroundColor = UIColor.Zap.background
    }
}

extension ProductSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension ProductSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
