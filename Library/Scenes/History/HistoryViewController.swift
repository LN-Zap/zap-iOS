//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import UIKit

extension UIStoryboard {
    static func instantiateHistoryViewController(historyViewModel: HistoryViewModel, presentTransactionDetail: @escaping (TransactionViewModel) -> Void, presentFilter: @escaping () -> Void) -> UINavigationController {
        let viewController = Storyboard.history.instantiate(viewController: HistoryViewController.self)
        
        viewController.historyViewModel = historyViewModel
        viewController.presentTransactionDetail = presentTransactionDetail
        viewController.presentFilter = presentFilter
        
        let navigationController = ZapNavigationController(rootViewController: viewController)
        navigationController.tabBarItem.title = "scene.history.title".localized
        navigationController.tabBarItem.image = UIImage(named: "tabbar_wallet", in: Bundle.library, compatibleWith: nil)

        return navigationController
    }
}

final class HistoryViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView?
    @IBOutlet private weak var emptyStateLabel: UILabel!
    
    fileprivate var presentFilter: (() -> Void)?
    fileprivate var presentTransactionDetail: ((TransactionViewModel) -> Void)?
    fileprivate var historyViewModel: HistoryViewModel?
    
    deinit {    
        tableView?.isEditing = false // fixes Bond bug. Binding is not released in editing mode.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "scene.history.title".localized
        
        guard let tableView = tableView else { return }
        view.backgroundColor = UIColor.Zap.background

        let searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController

        Style.Label.body.apply(to: emptyStateLabel)
        emptyStateLabel.text = "scene.history.empty_state_label".localized
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 82
        tableView.registerCell(HistoryCell.self)
        tableView.registerCell(HeaderTableViewCell.self)
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        historyViewModel?.dataSource
            .bind(to: tableView) { dataSource, indexPath, tableView in
                switch dataSource[indexPath.row] {
                case .header(let title):
                    let cell: HeaderTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
                    cell.headerText = title
                    return cell
                case .transactionEvent(let transactionEvent):
                    let cell: HistoryCell = tableView.dequeueCellForIndexPath(indexPath)
                    cell.setTransactionEvent(transactionEvent)
                    return cell
                case .channelEvent(let channelEvent):
                    let cell: HistoryCell = tableView.dequeueCellForIndexPath(indexPath)
                    cell.setChannelEvent(channelEvent)
                    return cell
                case .createInvoiceEvent(let createInvoiceEvent):
                    let cell: HistoryCell = tableView.dequeueCellForIndexPath(indexPath)
                    cell.setCreateInvoiceEvent(createInvoiceEvent)
                    return cell
                case .failedPayemntEvent(let failedPayemntEvent):
                    let cell: HistoryCell = tableView.dequeueCellForIndexPath(indexPath)
                    cell.setFailedPayemntEvent(failedPayemntEvent)
                    return cell
                }
            }
            .dispose(in: reactive.bag)
        
        [historyViewModel?.isEmpty
            .bind(to: tableView.reactive.isHidden),
         historyViewModel?.isEmpty
            .map { !$0 }
            .bind(to: emptyStateLabel.reactive.isHidden)]
            .dispose(in: reactive.bag)
    }
    
    @IBAction private func presentFilter(_ sender: Any) {
        presentFilter?()
    }
    
    @objc func refresh(sender: UIRefreshControl) {
//        historyViewModel?.refresh()
        sender.endRefreshing()
    }
}

extension HistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
//        if let historyViewModel = historyViewModel,
//            case .cell(let transactionViewModel) = historyViewModel.dataSource.item(at: indexPath.row) {
//            presentTransactionDetail?(transactionViewModel)
//        }
    }
    
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        if let historyViewModel = historyViewModel,
//            case .cell(let transactionViewModel) = historyViewModel.dataSource.item(at: indexPath.row) {
//            if transactionViewModel.annotation.value.isHidden {
//                return [archiveAction(title: "scene.history.row_action.unarchive".localized, color: UIColor.Zap.superGreen, setHidden: false)]
//            } else {
//                return [archiveAction(title: "scene.history.row_action.archive".localized, color: UIColor.Zap.superRed, setHidden: true)]
//            }
//        }
//        return []
//    }
//
//    private func archiveAction(title: String, color: UIColor, setHidden hidden: Bool) -> UITableViewRowAction {
//        let archiveAction = UITableViewRowAction(style: .destructive, title: title) { [weak self] _, indexPath in
//            if let historyViewModel = self?.historyViewModel,
//                case .cell(let transactionViewModel) = historyViewModel.dataSource.item(at: indexPath.row) {
//                historyViewModel.setTransactionHidden(transactionViewModel.transaction, hidden: hidden)
//            }
//        }
//        archiveAction.backgroundColor = color
//        return archiveAction
//    }
}

extension HistoryViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension HistoryViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            historyViewModel?.searchString.value = text
        }
    }
}
