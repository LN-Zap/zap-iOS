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
        
        let navigationController = ModalNavigationController(rootViewController: viewController, height: 480)
        
        navigationController.navigationBar.backgroundColor = UIColor.Zap.seaBlueGradient
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        return navigationController
    }
}

final class FilterViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    fileprivate var historyViewModel: HistoryViewModel?
    
    let sections: [Section<FilterSetting>] = [
        Section(title: "scene.filter.section_header.transaction_types".localized, rows: [
            .transactionEvents,
            .lightningPaymentEvents
        ]),
        Section(title: nil, rows: [
            .failedPaymentEvents,
            .createInvoiceEvents,
            .channelEvents
        ]),
        Section(title: "scene.filter.section_header.advanced".localized, rows: [
            .unknownTransactionType
        ])
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
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let filterSettings = historyViewModel?.filterSettings else { fatalError("ViewModel not set") }
        
        let cell: FilterTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
        let filterSetting = sections[indexPath.section][indexPath.row]
        cell.set(filterSetting: filterSetting, from: filterSettings)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
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
