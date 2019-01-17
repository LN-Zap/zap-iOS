//
//  Library
//
//  Created by Otto Suess on 21.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import Lightning

extension UIStoryboard {
    static func instantiateProductSearchViewController(transactionService: TransactionService, shoppingCartViewModel: ShoppingCartViewModel, productSearchViewModel: ProductSearchViewModel) -> ProductSearchViewController {
        let productSearchViewController = StoryboardScene.PoS.productSearchViewController.instantiate()
        
        productSearchViewController.transactionService = transactionService
        productSearchViewController.shoppingCartViewModel = shoppingCartViewModel
        productSearchViewController.productSearchViewModel = productSearchViewModel

        return productSearchViewController
    }
}

final class ProductSearchViewController: UIViewController, ShoppingCartPresentable, ChargePresentable {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var payButton: UIButton!
    private weak var searchBar: UISearchBar?
    
    // swiftlint:disable implicitly_unwrapped_optional
    fileprivate var shoppingCartViewModel: ShoppingCartViewModel!
    fileprivate var productSearchViewModel: ProductSearchViewModel!
    fileprivate var transactionService: TransactionService!
    // swiftlint:enable implicitly_unwrapped_optional
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        definesPresentationContext = true

        navigationController?.view.backgroundColor = UIColor.Zap.background
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchBar = searchController.searchBar
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
        tableView.separatorColor = UIColor.Zap.slateBlue
        view.backgroundColor = UIColor.Zap.background
        
        setupChargeButton(button: payButton, amount: shoppingCartViewModel.totalAmount)
        
        setupShoppingCartBarButton(shoppingCartViewModel: shoppingCartViewModel, selector: #selector(presentShoppingCart))
        
        productSearchViewModel.items.bind(to: tableView) { [shoppingCartViewModel] items, indexPath, tableView -> UITableViewCell in
            if let product = items[indexPath.row] as? Product,
                let shoppingCartViewModel = shoppingCartViewModel {
                let cell: SearchProductCell = tableView.dequeueCellForIndexPath(indexPath)
                let count = shoppingCartViewModel.count(of: product)
                cell.setItem(product: product, count: count)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell") ?? ProductSearchViewController.createNewCell()
                
                cell.textLabel?.text = items[indexPath.row].name
                if items[indexPath.row] is Group {
                    cell.accessoryType = .disclosureIndicator
                }
                
                return cell
            }
        }
    }
    
    private static func createNewCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "DefaultCell")
        cell.backgroundColor = UIColor.Zap.background
        if let cellLabel = cell.textLabel {
            Style.Label.body.apply(to: cellLabel)
        }
        return cell
    }
    
    @IBAction private func presentTipViewController(_ sender: Any) {
        presentChargeViewController(transactionService: transactionService, fiatValue: shoppingCartViewModel.totalAmount.value, shoppingCartViewModel: shoppingCartViewModel)
    }
    
    @objc func presentShoppingCart() {
        presentShoppingCart(shoppingCartViewModel: shoppingCartViewModel, transactionService: transactionService)
    }
}

extension ProductSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        searchBar?.endEditing(true)
        let groupable = productSearchViewModel.items[indexPath.row]
        if let group = groupable as? Group {
            let productSearchViewModel = ProductSearchViewModel(group: group)
            let detailViewController = UIStoryboard.instantiateProductSearchViewController(transactionService: transactionService, shoppingCartViewModel: shoppingCartViewModel, productSearchViewModel: productSearchViewModel)
            navigationController?.pushViewController(detailViewController, animated: true)
        } else if let product = groupable as? Product {
            shoppingCartViewModel.addSingle(product: product)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar?.resignFirstResponder()
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
