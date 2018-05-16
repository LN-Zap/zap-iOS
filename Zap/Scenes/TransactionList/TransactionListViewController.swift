//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import UIKit

final class TransactionBond: TableViewBinder<Observable2DArray<String, TransactionType>> {
    override func cellForRow(at indexPath: IndexPath, tableView: UITableView, dataSource: Observable2DArray<String, TransactionType>) -> UITableViewCell {
        let transaction = dataSource.item(at: indexPath)

        switch transaction {
            
        case .onChainTransaction(let viewModel):
            let cell: OnChainTransactionTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
            cell.onChainTransaction = viewModel
            return cell
        case .lightningPayment(let viewModel):
            let cell: LightningPaymentTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
            cell.payment = viewModel
            return cell
        case .lightningInvoice(let viewModel):
            let cell: LightningInvoiceTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
            cell.invoice = viewModel
            return cell
        }
    }
    
    func titleForHeader(in section: Int, dataSource: Observable2DArray<String, TransactionType>) -> String? {
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
        
        tableView.rowHeight = 66
        tableView.registerCell(OnChainTransactionTableViewCell.self)
        tableView.registerCell(LightningPaymentTableViewCell.self)
        tableView.registerCell(LightningInvoiceTableViewCell.self)
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        transactionListViewModel?.sections.bind(to: tableView, using: TransactionBond())

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
        let viewController: UINavigationController
        
        switch transactionType {
        case .onChainTransaction(let viewModel):
            viewController = Storyboard.transactionDetail.initial(viewController: UINavigationController.self)
            if let transactionDetailViewController = viewController.topViewController as? TransactionDetailViewController {
                transactionDetailViewController.transactionViewModel = viewModel
            }
        case .lightningPayment(let viewModel):
            viewController = Storyboard.paymentDetail.initial(viewController: UINavigationController.self)
            if let paymentDetailViewController = viewController.topViewController as? PaymentDetailViewController {
                paymentDetailViewController.lightningPaymentViewModel = viewModel
            }
        case .lightningInvoice(let viewModel):
            viewController = Storyboard.invoiceDetail.initial(viewController: UINavigationController.self)
            if let invoiceDetailViewController = viewController.topViewController as? InvoiceDetailViewController {
                invoiceDetailViewController.lightningInvoiceViewModel = viewModel
            }
        }
        
        present(viewController, animated: true, completion: nil)
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
            let transactionType = transactionListViewModel?.sections.item(at: indexPath) {
            viewModel?.hideTransaction(transactionType.transactionViewModel)
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
