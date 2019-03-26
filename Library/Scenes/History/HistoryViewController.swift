//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Lightning
import UIKit

final class HistoryViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView?
    @IBOutlet private weak var emptyStateLabel: UILabel!

    private var historyViewModel: HistoryViewModel?
    private var presentFilter: (() -> Void)?
    private var presentDetail: ((HistoryEventType) -> Void)?
    private var presentSend: ((String?) -> Void)?

    deinit {
        tableView?.isEditing = false // fixes Bond bug. Binding is not released in editing mode.
    }

    static func instantiate(historyViewModel: HistoryViewModel, presentFilter: @escaping () -> Void, presentDetail: @escaping (HistoryEventType) -> Void, presentSend: @escaping (String?) -> Void) -> HistoryViewController {
        let viewController = StoryboardScene.History.historyViewController.instantiate()

        viewController.historyViewModel = historyViewModel
        viewController.presentFilter = presentFilter
        viewController.presentDetail = presentDetail
        viewController.presentSend = presentSend

        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard
            let tableView = tableView,
            let historyViewModel = historyViewModel
            else { return }

        title = L10n.Scene.History.title
        definesPresentationContext = true
        view.backgroundColor = UIColor.Zap.background

        let searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController

        Style.Label.body.apply(to: emptyStateLabel)
        emptyStateLabel.text = L10n.Scene.History.emptyStateLabel

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 82
        tableView.registerCell(HistoryCell.self)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)

        setupDataSourceBinding(tableView, historyViewModel)

        historyViewModel.dataSource
            .map { !$0.collection.children.isEmpty }
            .bind(to: emptyStateLabel.reactive.isHidden)
            .dispose(in: reactive.bag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        historyViewModel?.historyWillAppear()
    }

    private func setupDataSourceBinding(_ tableView: UITableView, _ historyViewModel: HistoryViewModel) {
        historyViewModel.dataSource
            .bind(to: tableView) { dataSource, indexPath, tableView in
                let cell: HistoryCell = tableView.dequeueCellForIndexPath(indexPath)

                switch dataSource.item(at: indexPath) {
                case .transactionEvent(let transactionEvent):
                    cell.setTransactionEvent(transactionEvent)
                case .channelEvent(let channelEvent):
                    cell.setChannelEvent(channelEvent)
                case .createInvoiceEvent(let createInvoiceEvent):
                    cell.setCreateInvoiceEvent(createInvoiceEvent)
                case .failedPaymentEvent(let failedPayemntEvent):
                    cell.setFailedPaymentEvent(failedPayemntEvent, delegate: self)
                case .lightningPaymentEvent(let lightningPaymentEvent):
                    cell.setLightningPaymentEvent(lightningPaymentEvent)
                }

                if historyViewModel.isEventNew(at: indexPath) {
                    cell.addNotificationLabel(type: .new)
                }

                return cell
            }
            .dispose(in: reactive.bag)
    }

    @IBAction private func presentFilter(_ sender: Any) {
        presentFilter?()
    }
}

extension HistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let event = historyViewModel?.dataSource.collection.item(at: indexPath) else { return }
        presentDetail?(event)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView = SectionHeaderView.instanceFromNib
        sectionHeaderView.title = historyViewModel?.dataSource.collection[sectionAt: section].metadata
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
            historyViewModel?.searchString = text
        }
    }
}

extension HistoryViewController: HistoryCellDelegate {
    func resendFailedPayment(_ failedPaymentEvent: FailedPaymentEvent) {
        presentSend?(failedPaymentEvent.paymentRequest)
    }
}
