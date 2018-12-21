//
//  Library
//
//  Created by Otto Suess on 20.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

extension UIStoryboard {
    static func instantiateShoppingCartViewController(shoppingCartViewModel: ShoppingCartViewModel) -> ShoppingCartViewController {
        let shoppingCartViewController = StoryboardScene.PoS.shoppingCartViewController.instantiate()
        shoppingCartViewController.shoppingCartViewModel = shoppingCartViewModel
        return shoppingCartViewController
    }
}

final class ShoppingCartViewController: UIViewController {
    var shoppingCartViewModel: ShoppingCartViewModel?
    
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Shopping Cart"
        view.backgroundColor = UIColor.Zap.background

        tableView.registerCell(ShoppingListTableViewCell.self)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 54
        tableView.allowsMultipleSelectionDuringEditing = false
        tableView.backgroundColor = UIColor.Zap.background
        tableView.tableFooterView = UIView(frame: .zero)
    }
}

extension ShoppingCartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ShoppingCartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingCartViewModel?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ShoppingListTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
        cell.selectedItem = shoppingCartViewModel?.items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            shoppingCartViewModel?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
