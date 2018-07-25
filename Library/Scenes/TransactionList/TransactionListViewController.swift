//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import UIKit

extension UIStoryboard {
    static func instantiateTransactionListViewController(transactionListViewModel: TransactionListViewModel, presentTransactionDetail: @escaping (TransactionViewModel) -> Void, presentFilter: @escaping () -> Void) -> UINavigationController {
        let viewController = Storyboard.transactionList.instantiate(viewController: TransactionListViewController.self)
        
        viewController.transactionListViewModel = transactionListViewModel
        viewController.presentTransactionDetail = presentTransactionDetail
        viewController.presentFilter = presentFilter
        
        let navigationController = ZapNavigationController(rootViewController: viewController)
        navigationController.tabBarItem.title = "Transactions"
        navigationController.tabBarItem.image = UIImage(named: "tabbar_wallet", in: Bundle.library, compatibleWith: nil)

        return navigationController
    }
}

final class TransactionListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView?
    @IBOutlet private weak var emptyStateLabel: UILabel!
    @IBOutlet private weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    fileprivate var presentFilter: (() -> Void)?
    fileprivate var presentTransactionDetail: ((TransactionViewModel) -> Void)?
    fileprivate var transactionListViewModel: TransactionListViewModel?
    
    deinit {    
        tableView?.isEditing = false // fixes Bond bug. Binding is not released in editing mode.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "scene.transactions.title".localized
        
        guard let tableView = tableView else { return }
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController

        Style.label.apply(to: emptyStateLabel)
        emptyStateLabel.text = "scene.transactions.empty_state_label".localized
        
        tableView.rowHeight = 66
        tableView.registerCell(TransactionTableViewCell.self)
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        transactionListViewModel?.dataSource
            .bind(to: tableView) { dataSource, indexPath, tableView in
                let cell: TransactionTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
                cell.transactionViewModel = dataSource[indexPath]
                return cell
            }
            .dispose(in: reactive.bag)
        
        [transactionListViewModel?.isLoading
            .map { !$0 }
            .bind(to: loadingActivityIndicator.reactive.isHidden),
         transactionListViewModel?.isEmpty
            .bind(to: tableView.reactive.isHidden),
         transactionListViewModel?.isEmpty
            .map { !$0 }
            .bind(to: emptyStateLabel.reactive.isHidden)]
            .dispose(in: reactive.bag)
    }
    
    @IBAction private func presentFilter(_ sender: Any) {
        presentFilter?()
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        transactionListViewModel?.refresh()
        sender.endRefreshing()
    }
}

extension TransactionListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView = SectionHeaderView.instanceFromNib
        sectionHeaderView.title = transactionListViewModel?.dataSource[section].metadata
        sectionHeaderView.backgroundColor = .white
        return sectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let transactionListViewModel = transactionListViewModel else { return }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let transactionViewModel = transactionListViewModel.dataSource.item(at: indexPath)
        presentTransactionDetail?(transactionViewModel)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let transactionViewModel = transactionListViewModel?.dataSource.item(at: indexPath) else { return nil }
        
        if transactionViewModel.annotation.value.isHidden {
            return [archiveAction(title: "scene.transactions.row_action.unarchive".localized, color: UIColor.zap.nastyGreen, setHidden: false)]
        } else {
            return [archiveAction(title: "scene.transactions.row_action.archive".localized, color: UIColor.zap.tomato, setHidden: true)]
        }
    }
    
    private func archiveAction(title: String, color: UIColor, setHidden hidden: Bool) -> UITableViewRowAction {
        let archiveAction = UITableViewRowAction(style: .destructive, title: title) { [weak self] _, indexPath in
            guard let transactionListViewModel = self?.transactionListViewModel else { return }
            let transactionViewModel = transactionListViewModel.dataSource.item(at: indexPath)
            transactionListViewModel.setTransactionHidden(transactionViewModel.transaction, hidden: hidden)
        }
        archiveAction.backgroundColor = color
        return archiveAction
    }
}

extension TransactionListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension TransactionListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            transactionListViewModel?.searchString.value = text
        }
    }
}
