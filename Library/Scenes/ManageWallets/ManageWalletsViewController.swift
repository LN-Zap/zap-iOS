//
//  Library
//
//  Created by Otto Suess on 01.02.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Lightning
import UIKit

final class ManageWalletsViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    // swiftlint:disable implicitly_unwrapped_optional
    private var addWalletButtonTapped: (() -> Void)!
    private var manageWalletsViewModel: ManageWalletsViewModel!
    private var connectWallet: ((LightningConnection) -> Void)!
    // swiftlint:enable implicitly_unwrapped_optional

    static func instantiate(addWalletButtonTapped: @escaping () -> Void, manageWalletsViewModel: ManageWalletsViewModel, connectWallet: @escaping (LightningConnection) -> Void) -> ManageWalletsViewController {
        let viewController = StoryboardScene.ManageWallets.manageWalletsViewController.instantiate()
        viewController.addWalletButtonTapped = addWalletButtonTapped
        viewController.manageWalletsViewModel = manageWalletsViewModel
        viewController.connectWallet = connectWallet
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        title = L10n.Scene.ManageWallets.title
        tableView.registerCell(ManageWalletTableViewCell.self)
        tableView.rowHeight = 76
        tableView.backgroundColor = UIColor.Zap.background
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelectionDuringEditing = false
    }

    @IBAction private func addWallet(_ sender: Any) {
        addWalletButtonTapped()
    }
}

extension ManageWalletsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let walletConfiguration = manageWalletsViewModel.sections[indexPath.section][indexPath.row]
        connectWallet(walletConfiguration.connection)
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard
            let view = view as? UITableViewHeaderFooterView,
            let label = view.textLabel
            else { return }
        label.text = view.textLabel?.text?.capitalized
        Style.Label.body.apply(to: label)
        view.backgroundView?.backgroundColor = UIColor.Zap.seaBlue
    }
}

extension ManageWalletsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return manageWalletsViewModel.sections.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return manageWalletsViewModel.sections[section].title
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manageWalletsViewModel.sections[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ManageWalletTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
        cell.configure(manageWalletsViewModel.sections[indexPath.section][indexPath.row])
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return manageWalletsViewModel.sections[indexPath.section][indexPath.row].connection != .local
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let initialSectionCount = manageWalletsViewModel.sections.count
        manageWalletsViewModel.removeItem(at: indexPath)

        if initialSectionCount != manageWalletsViewModel.sections.count {
            tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
        } else {
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension ManageWalletsViewController: ManageWalletTableViewCellDelegate {
    func presentBackupViewController(nodePubKey: String) {
        let viewController = ChannelBackupViewController.instantiate(nodePubKey: nodePubKey)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
