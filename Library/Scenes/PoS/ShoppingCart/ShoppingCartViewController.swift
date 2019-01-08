//
//  Library
//
//  Created by Otto Suess on 20.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import Lightning

extension UIStoryboard {
    static func instantiateShoppingCartViewController(shoppingCartViewModel: ShoppingCartViewModel, transactionService: TransactionService) -> ShoppingCartViewController {
        let shoppingCartViewController = StoryboardScene.PoS.shoppingCartViewController.instantiate()
        shoppingCartViewController.shoppingCartViewModel = shoppingCartViewModel
        shoppingCartViewController.transactionService = transactionService
        return shoppingCartViewController
    }
}

final class ShoppingCartViewController: UIViewController, ChargePresentable {
    // swiftlint:disable implicitly_unwrapped_optional
    fileprivate var shoppingCartViewModel: ShoppingCartViewModel!
    fileprivate var transactionService: TransactionService!
    // swiftlint:enable implicitly_unwrapped_optional
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var payButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Shopping Cart"
        view.backgroundColor = UIColor.Zap.background

        tableView.registerCell(ShoppingListTableViewCell.self)
        
        tableView.allowsSelection = false
        tableView.dataSource = self
        tableView.rowHeight = 76
        tableView.allowsMultipleSelectionDuringEditing = false
        tableView.backgroundColor = UIColor.Zap.background
        tableView.tableFooterView = UIView(frame: .zero)
        
        setupChargeButton(button: payButton, amount: shoppingCartViewModel.totalAmount)
    }
    
    @IBAction private func clearShoppingCart(_ sender: Any) {
        shoppingCartViewModel?.removeAll()
        tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func presentChargeViewController(_ sender: Any) {
        presentChargeViewController(transactionService: transactionService, fiatValue: shoppingCartViewModel.totalAmount.value)
    }
}

extension ShoppingCartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingCartViewModel?.selectedItems.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ShoppingListTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
        cell.selectedItem = shoppingCartViewModel?.selectedItems[indexPath.row]
        cell.shoppingCartViewModel = shoppingCartViewModel
        return cell
    }
}
