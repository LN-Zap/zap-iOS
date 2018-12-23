//
//  Library
//
//  Created by Otto Suess on 21.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

extension UIStoryboard {
    static func instantiateProductSearchViewController(shoppingCartViewModel: ShoppingCartViewModel, productsViewModel: ProductsViewModel, productGroup: Group) -> ProductSearchViewController {
        let productSearchViewController = StoryboardScene.PoS.productSearchViewController.instantiate()
        
        productSearchViewController.shoppingCartViewModel = shoppingCartViewModel
        productSearchViewController.productsViewModel = productsViewModel
        productSearchViewController.productGroup = productGroup

        return productSearchViewController
    }
}

final class ProductSearchViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    // swiftlint:disable implicitly_unwrapped_optional
    fileprivate var shoppingCartViewModel: ShoppingCartViewModel!
    fileprivate var productsViewModel: ProductsViewModel!
    fileprivate var productGroup: Group!
    // swiftlint:enable implicitly_unwrapped_optional
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = productGroup.name
        
        tableView.registerCell(SearchProductCell.self)
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.backgroundColor = UIColor.Zap.background
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 76
        view.backgroundColor = UIColor.Zap.background
    }
}

extension ProductSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let groupable = productGroup.items[indexPath.row]
        if let group = groupable as? Group {
            let detailViewController = UIStoryboard.instantiateProductSearchViewController(shoppingCartViewModel: shoppingCartViewModel, productsViewModel: productsViewModel, productGroup: group)
            navigationController?.pushViewController(detailViewController, animated: true)
        } else if let product = groupable as? Product {
            shoppingCartViewModel.addSingle(product: product)
        }
    }
}

extension ProductSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productGroup.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let product = productGroup.items[indexPath.row] as? Product {
            let cell: SearchProductCell = tableView.dequeueCellForIndexPath(indexPath)
            let count = shoppingCartViewModel.count(of: product)
            cell.setItem(product: product, count: count)
            return cell
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "test")
            
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: "test")
                cell?.backgroundColor = UIColor.Zap.background
                Style.Label.body.apply(to: cell!.textLabel!)
            }
            
            cell?.textLabel?.text = productGroup.items[indexPath.row].name
            if productGroup.items[indexPath.row] is Group {
                cell?.accessoryType = .disclosureIndicator
            }
            
            return cell! // swiftlint:disable:this force_unwrapping
        }
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
