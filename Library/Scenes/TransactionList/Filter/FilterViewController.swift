//
//  Library
//
//  Created by Otto Suess on 04.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static func instantiateFilterViewController(transactionListViewModel: TransactionListViewModel) -> UINavigationController {
        let viewController = Storyboard.transactionList.instantiate(viewController: FilterViewController.self)
        viewController.transactionListViewModel = transactionListViewModel
        
        let size = CGSize(width: UIScreen.main.bounds.width, height: 365)
        return ModalNavigationController(rootViewController: viewController, size: size)
    }
}

final class FilterViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    fileprivate var transactionListViewModel: TransactionListViewModel?
    
    let cells: [[FilterSetting]] = [
        [
            .displayOnChainTransactions,
            .displayLightningPayments,
            .displayLightningInvoices
        ],
        [
            .displayArchivedTransactions
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "scene.filter.title".localized
        titleTextStyle = .dark
        
        tableView.allowsSelection = false
    }
    
    @IBAction private func dismissFilterViewController(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension FilterViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let filterSettings = transactionListViewModel?.filterSettings.value else { fatalError("ViewModel not set") }
        
        let cell: FilterTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
        let filterSetting = cells[indexPath.section][indexPath.row]
        cell.set(filterSetting: filterSetting, from: filterSettings)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "scene.filter.section_header.transaction_types".localized
        }
        return nil
    }
}

extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let view = view as? UITableViewHeaderFooterView else { return }
        view.textLabel?.font = UIFont.zap.light
        view.textLabel?.text = view.textLabel?.text?.capitalized
    }
}

extension FilterViewController: FilterTableViewCellDelegate {
    func setFilterSetting(_ filterSetting: FilterSetting, active: Bool) {
        guard let filterSettings = transactionListViewModel?.filterSettings.value else { return }
        let newFilterSettings = filterSetting.setActive(active, in: filterSettings)
        transactionListViewModel?.updateFilterSettings(newFilterSettings)
    }
}
