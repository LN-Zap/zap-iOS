//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import UIKit

extension UIStoryboard {
    static func instantiateTransactionListViewController(with viewModel: ViewModel) -> TransactionListViewController {
        let viewController = Storyboard.transactionList.initial(viewController: TransactionListViewController.self)
        viewController.viewModel = viewModel
        return viewController
    }
}

final class TransactionBond: TableViewBinder<Observable2DArray<String, TransactionViewModel>> {
    override func cellForRow(at indexPath: IndexPath, tableView: UITableView, dataSource: Observable2DArray<String, TransactionViewModel>) -> UITableViewCell {
        let viewModel = dataSource.item(at: indexPath)
        
        let cell: TransactionTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
        cell.transaction = viewModel
        return cell
    }
    
    func titleForHeader(in section: Int, dataSource: Observable2DArray<String, TransactionViewModel>) -> String? {
        return dataSource[section].metadata
    }
}

class TransactionListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView?
    @IBOutlet private weak var searchBackgroundView: UIView!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var emptyStateLabel: UILabel!
    
    fileprivate var viewModel: ViewModel? {
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
        
        searchBar.placeholder = "search"
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        searchBackgroundView.backgroundColor = UIColor.zap.searchBackground
        
        Style.label.apply(to: emptyStateLabel)
        emptyStateLabel.text = "0 transactions 🙁"
        
        tableView.rowHeight = 66
        tableView.registerCell(TransactionTableViewCell.self)
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        transactionListViewModel?.sections.bind(to: tableView, using: TransactionBond())

        let isDataSourceEmpty = transactionListViewModel?.sections
            .map {
                $0.dataSource.isEmpty
            }
        
        [isDataSourceEmpty?
            .bind(to: tableView.reactive.isHidden),
         isDataSourceEmpty?
            .map { !$0 }
            .bind(to: emptyStateLabel.reactive.isHidden)]
            .dispose(in: reactive.bag)
        
        tableView.delegate = self
        tableView.reactive.dataSource.forwardTo = self
    }
    
    @objc
    func refresh(sender: UIRefreshControl) {
        viewModel?.updateTransactions()
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
        
        let transactionType = transactionListViewModel.sections.item(at: indexPath)
        
        present(viewControllerFor(transactionType), animated: true, completion: nil)
    }
    
    private func viewControllerFor(_ transactionViewModel: TransactionViewModel) -> UIViewController {
        guard let viewModel = viewModel else { fatalError("viewModel not set") }
        return UIStoryboard.instantiateTransactionDetailViewController(with: viewModel, transactionViewModel: transactionViewModel)
    }
}

extension TransactionListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fatalError("This will never be called.")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("This will never be called.")
    }
        
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete,
            let transactionViewModel = transactionListViewModel?.sections.item(at: indexPath) {
            viewModel?.hideTransaction(transactionViewModel)
        }
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
