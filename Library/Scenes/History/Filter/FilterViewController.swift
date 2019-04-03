//
//  Library
//
//  Created by Otto Suess on 04.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class FilterViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    private var historyViewModel: HistoryViewModel?

    let sections: [Section<FilterSetting>] = [
        Section(title: L10n.Scene.Filter.SectionHeader.transactionTypes, rows: [
            .transactionEvents,
            .lightningPaymentEvents
        ]),
        Section(title: nil, rows: [
            .createInvoiceEvents,
            .expiredInvoiceEvents,
            .channelEvents
        ])
    ]

    static func instantiate(historyViewModel: HistoryViewModel) -> FilterViewController {
        let viewController = StoryboardScene.History.filterViewController.instantiate()
        viewController.historyViewModel = historyViewModel
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.Scene.Filter.title

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
