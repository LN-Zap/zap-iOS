//
//  Zap
//
//  Created by Otto Suess on 18.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import UIKit

extension UIStoryboard {
    static func instantiateDetailViewController(detailViewModel: DetailViewModel, dismissButtonTapped: @escaping () -> Void, safariButtonTapped: @escaping (URL) -> Void) -> UINavigationController {
        let viewController = Storyboard.detail.initial(viewController: UINavigationController.self)
        if let detailViewController = viewController.topViewController as? DetailViewController {
            detailViewController.detailViewModel = detailViewModel
            detailViewController.dismissButtonTapped = dismissButtonTapped
            detailViewController.safariButtonTapped = safariButtonTapped
        }
        return viewController
    }
}

final class DetailViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    var dismissButtonTapped: (() -> Void)?
    var safariButtonTapped: ((URL) -> Void)?
    
    var detailViewModel: DetailViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .white
        
        title = detailViewModel?.detailViewControllerTitle
        titleTextStyle = .dark
        
        tableView.registerCell(DetailTableViewCell.self)
        tableView.registerCell(DetailMemoTableViewCell.self)
        tableView.registerCell(DetailQRCodeTableViewCell.self)
        tableView.registerCell(DetailTimerTableViewCell.self)
        tableView.registerCell(DetailLegendTableViewCell.self)
        tableView.registerCell(DetailBalanceTableViewCell.self)
        tableView.registerCell(DetailSeparatorTableViewCell.self)
        tableView.registerCell(DetailDestructiveActionTableViewCell.self)
        tableView.registerCell(DetailTransactionHashTableViewCell.self)

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 48
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        
        detailViewModel?.detailCells
            .bind(to: tableView, createCell: createCell)
            .dispose(in: reactive.bag)
    }
    
    private func createCell(data: ObservableArray<DetailCellType>, indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        switch data[indexPath.row] {
        case .info(let info):
            let cell: DetailTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
            cell.info = info
            return cell
        case .memo(let info):
            let cell: DetailMemoTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
            cell.onChange = { [weak self] _ in
                guard let transactionViewModel = self?.detailViewModel as? TransactionViewModel else { return } // TODO: always fails
//                self?.viewModel?.udpateMemo($0, for: transactionViewModel)
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
        case .destructiveAction(let info):
            let cell: DetailDestructiveActionTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
            cell.delegate = self
            cell.info = info
            return cell
        case .transactionHash(let info):
            let cell: DetailTransactionHashTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
            cell.delegate = self
            cell.info = info
            return cell
        }
    }
    
    @IBAction private func doneButtonTapped(_ sender: Any) {
        dismissButtonTapped?()
    }
}

extension DetailViewController: DetailCellDelegate {
    func dismiss() {
        dismissButtonTapped?()
    }
    
    func presentSafariViewController(for url: URL) {
        safariButtonTapped?(url)
    }
}
