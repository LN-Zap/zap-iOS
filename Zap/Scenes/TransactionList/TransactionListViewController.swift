//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import UIKit

struct TransactionBond: TableViewBond {
    func cellForRow(at indexPath: IndexPath, tableView: UITableView, dataSource: Observable2DArray<String, Transaction>) -> UITableViewCell {
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
    
    func titleForHeader(in section: Int, dataSource: Observable2DArray<String, Transaction>) -> String? {
        return dataSource[section].metadata
    }
}

class TransactionListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView?
    
    var viewModel: ViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            transactionViewModel = TransactionListViewModel(viewModel: viewModel)
        }
    }
    private var transactionViewModel: TransactionListViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "scene.transactions.title".localized
        
        guard let tableView = tableView else { return }
        
        tableView.rowHeight = 50
        tableView.registerCell(OnChainTransactionTableViewCell.self)
        tableView.registerCell(PaymentTableViewCell.self)
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        transactionViewModel?.sections.bind(to: tableView, using: TransactionBond())

        tableView.delegate = self
        tableView.allowsSelection = false
    }
    
    @objc
    func refresh(sender: UIRefreshControl) {
        sender.endRefreshing()
    }
}

extension TransactionListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView = SectionHeaderView.instanceFromNib
        sectionHeaderView.title = transactionViewModel?.sections[section].metadata
        sectionHeaderView.backgroundColor = .white
        return sectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }    
}
