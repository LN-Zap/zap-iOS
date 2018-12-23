//
//  Library
//
//  Created by Otto Suess on 21.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

extension UIStoryboard {
    static func instantiateProductSearchViewController(shoppingCartViewModel: ShoppingCartViewModel, productsViewModel: ProductsViewModel, productSearchViewModel: ProductSearchViewModel) -> ProductSearchViewController {
        let productSearchViewController = StoryboardScene.PoS.productSearchViewController.instantiate()
        
        productSearchViewController.shoppingCartViewModel = shoppingCartViewModel
        productSearchViewController.productsViewModel = productsViewModel
        productSearchViewController.productSearchViewModel = productSearchViewModel

        return productSearchViewController
    }
}

final class ProductSearchViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    // swiftlint:disable implicitly_unwrapped_optional
    fileprivate var shoppingCartViewModel: ShoppingCartViewModel!
    fileprivate var productsViewModel: ProductsViewModel!
    fileprivate var productSearchViewModel: ProductSearchViewModel!
    // swiftlint:enable implicitly_unwrapped_optional
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = productSearchViewModel.title
        
        tableView.registerCell(SearchProductCell.self)
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.backgroundColor = UIColor.Zap.background
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 76
        view.backgroundColor = UIColor.Zap.background
        
        productSearchViewModel.items.bind(to: tableView) { [shoppingCartViewModel] items, indexPath, tableView -> UITableViewCell in
            if let product = items[indexPath.row] as? Product,
                let shoppingCartViewModel = shoppingCartViewModel {
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
                
                cell?.textLabel?.text = items[indexPath.row].name
                if items[indexPath.row] is Group {
                    cell?.accessoryType = .disclosureIndicator
                }
                
                return cell! // swiftlint:disable:this force_unwrapping
            }
        }
    }
}

extension ProductSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let groupable = productSearchViewModel.items[indexPath.row]
        if let group = groupable as? Group {
            let productSearchViewModel = ProductSearchViewModel(group: group)
            let detailViewController = UIStoryboard.instantiateProductSearchViewController(shoppingCartViewModel: shoppingCartViewModel, productsViewModel: productsViewModel, productSearchViewModel: productSearchViewModel)
            navigationController?.pushViewController(detailViewController, animated: true)
        } else if let product = groupable as? Product {
            shoppingCartViewModel.addSingle(product: product)
        }
    }
}

extension ProductSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fatalError("not implemented")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("not implemented")
    }
}

extension ProductSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension ProductSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        productSearchViewModel.searchString = searchController.searchBar.text
    }
}
