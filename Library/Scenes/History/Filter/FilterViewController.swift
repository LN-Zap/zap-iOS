//
//  Library
//
//  Created by Otto Suess on 04.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static func instantiateFilterViewController(historyViewModel: HistoryViewModel) -> UINavigationController {
        let viewController = Storyboard.history.instantiate(viewController: FilterViewController.self)
        viewController.historyViewModel = historyViewModel
        
        let navigationController = ModalNavigationController(rootViewController: viewController, height: 365)
        
        navigationController.navigationBar.backgroundColor = UIColor.Zap.seaBlueGradient
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        return navigationController
    }
}

final class FilterViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    fileprivate var historyViewModel: HistoryViewModel?
    
    let cells: [[FilterSetting]] = [
        [
            .transactionEvents,
            .lightningPaymentEvents
        ],
        [
            .failedPaymentEvents,
            .createInvoiceEvents,
            .channelEvents
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "scene.filter.title".localized
        
        tableView.allowsSelection = false
        tableView.backgroundColor = UIColor.Zap.deepSeaBlue
        tableView.separatorColor = UIColor.Zap.gray
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
        guard let filterSettings = historyViewModel?.filterSettings else { fatalError("ViewModel not set") }
        
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
        view.textLabel?.text = view.textLabel?.text?.capitalized
    }
}

extension FilterViewController: FilterTableViewCellDelegate {
    func setFilterSetting(_ filterSetting: FilterSetting, active: Bool) {
        guard let filterSettings = historyViewModel?.filterSettings else { return }
        historyViewModel?.filterSettings = filterSetting.setActive(active, in: filterSettings)
    }
}
