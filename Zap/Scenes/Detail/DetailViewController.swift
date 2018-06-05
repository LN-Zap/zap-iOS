//
//  Zap
//
//  Created by Otto Suess on 18.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import UIKit

class DetailViewController: UIViewController {
    @IBOutlet private weak var hideTransactionButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    
    var detailViewModel: DetailViewModel?
    var viewModel: ViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .white
        
        title = detailViewModel?.detailViewControllerTitle
        titleTextStyle = .dark
        
        Style.button.apply(to: hideTransactionButton)
        
        hideTransactionButton.setTitle("delete", for: .normal)
        hideTransactionButton.tintColor = UIColor.zap.tomato
        
        tableView.registerCell(DetailTableViewCell.self)
        tableView.registerCell(DetailMemoTableViewCell.self)
        tableView.registerCell(DetailQRCodeTableViewCell.self)
        tableView.registerCell(DetailTimerTableViewCell.self)
        tableView.registerCell(DetailLegendTableViewCell.self)
        tableView.registerCell(DetailBalanceTableViewCell.self)
        tableView.registerCell(DetailSeparatorTableViewCell.self)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 48
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        
        detailViewModel?.detailCells
            .bind(to: tableView) { data, indexPath, tableView -> UITableViewCell in
                switch data[indexPath.row] {
                case .info(let info):
                    let cell: DetailTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
                    cell.info = info
                    return cell
                case .memo(let info):
                    let cell: DetailMemoTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
                    cell.onChange = { [weak self] in
                        guard let transactionViewModel = self?.detailViewModel as? TransactionViewModel else { return }
                        self?.viewModel?.udpateMemo($0, for: transactionViewModel)
                    }
                    cell.info = info
                    return cell
                case .qrCode(let address):
                    let cell: DetailQRCodeTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
                    cell.address = address
                    cell.delegate = self
                    return cell
                case .timer(let info):
                    let cell: DetailTimerTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
                    cell.info = info
                    return cell
                case .legend(let info):
                    let cell: DetailLegendTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
                    cell.info = info
                    return cell
                case .balance(let info):
                    let cell: DetailBalanceTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
                    cell.info = info
                    return cell
                case .separator:
                    return tableView.dequeueCellForIndexPath(indexPath) as DetailSeparatorTableViewCell
                }
            }
    }
    
    @IBAction private func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // TODO: move to cell
    @IBAction private func hideTransaction(_ sender: Any) {
        guard let transactionViewModel = detailViewModel as? TransactionViewModel else { return }
        viewModel?.hideTransaction(transactionViewModel)
        dismiss(animated: true, completion: nil)
    }
}
