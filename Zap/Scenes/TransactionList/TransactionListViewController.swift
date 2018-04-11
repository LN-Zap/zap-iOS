//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import UIKit

struct TransactionBond: TableViewBond {
    func cellForRow(at indexPath: IndexPath, tableView: UITableView, dataSource: Observable2DArray<String, TransactionViewModel>) -> UITableViewCell {
        let transaction = dataSource.item(at: indexPath)

        if transaction.isOnChain {
            let cell: OnChainTransactionTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
            cell.onChainTransaction = transaction
            return cell
        } else {
            let cell: PaymentTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
            cell.payment = transaction
            return cell
        }
    }
    
    func titleForHeader(in section: Int, dataSource: Observable2DArray<String, TransactionViewModel>) -> String? {
        return dataSource[section].metadata
    }
}

class TransactionListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView?
    @IBOutlet private weak var searchBackgroundView: UIView!
    @IBOutlet private weak var searchBar: UISearchBar!

    var viewModel: ViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            transactionListViewModel = TransactionListViewModel(viewModel: viewModel)
        }
    }
    private var transactionListViewModel: TransactionListViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "scene.transactions.title".localized
        
        guard let tableView = tableView else { return }
        
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        searchBackgroundView.backgroundColor = Color.searchBackground
        
        tableView.rowHeight = 50
        tableView.registerCell(OnChainTransactionTableViewCell.self)
        tableView.registerCell(PaymentTableViewCell.self)
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        transactionListViewModel?.sections.bind(to: tableView, using: TransactionBond())

        tableView.delegate = self
    }
    
    @objc
    func refresh(sender: UIRefreshControl) {
        sender.endRefreshing()
    }
}

extension TransactionListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView = SectionHeaderView.instanceFromNib
        sectionHeaderView.title = transactionListViewModel?.sections[section].metadata
        sectionHeaderView.backgroundColor = .white
        return sectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let transactionListViewModel = transactionListViewModel else { return }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let transactionViewModel = transactionListViewModel.sections.item(at: indexPath)
        let viewController: UINavigationController
        if transactionViewModel.isOnChain {
            viewController = Storyboard.transactionDetail.initial(viewController: UINavigationController.self)
            if let transactionDetailViewController = viewController.topViewController as? TransactionDetailViewController {
                transactionDetailViewController.transactionViewModel = transactionViewModel
            }
        } else {
            viewController = Storyboard.paymentDetail.initial(viewController: UINavigationController.self)
        }
        present(viewController, animated: true, completion: nil)
    }
}

extension TransactionListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // TODO: search
        print(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
