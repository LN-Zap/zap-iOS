//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import UIKit

extension UIStoryboard {
    static func instantiateHistoryViewController(historyViewModel: HistoryViewModel, presentFilter: @escaping () -> Void) -> UINavigationController {
        let viewController = Storyboard.history.instantiate(viewController: HistoryViewController.self)
        
        viewController.historyViewModel = historyViewModel
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
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 82
        tableView.registerCell(HistoryCell.self)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        
        historyViewModel?.dataSource
            .bind(to: tableView) { dataSource, indexPath, tableView in
                switch dataSource[indexPath] {
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
                case .failedPaymentEvent(let failedPayemntEvent):
                    let cell: HistoryCell = tableView.dequeueCellForIndexPath(indexPath)
                    cell.setFailedPayemntEvent(failedPayemntEvent)
                    return cell
                case .lightningPaymentEvent(let lightningPaymentEvent):
                    let cell: HistoryCell = tableView.dequeueCellForIndexPath(indexPath)
                    cell.setLightningPaymentEvent(lightningPaymentEvent)
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
}

extension HistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // TODO: present detail
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView = SectionHeaderView.instanceFromNib
        sectionHeaderView.title = historyViewModel?.dataSource[section].metadata
        sectionHeaderView.backgroundColor = .white
        return sectionHeaderView
    }
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
