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
    private var walletConfigurationStore: WalletConfigurationStore!
    private var connectWallet: ((WalletConfiguration) -> Void)!
    // swiftlint:enable implicitly_unwrapped_optional

    static func instantiate(addWalletButtonTapped: @escaping () -> Void, walletConfigurationStore: WalletConfigurationStore, connectWallet: @escaping (WalletConfiguration) -> Void) -> ManageWalletsViewController {
        let viewController = StoryboardScene.ManageWallets.manageWalletsViewController.instantiate()
        viewController.addWalletButtonTapped = addWalletButtonTapped
        viewController.walletConfigurationStore = walletConfigurationStore
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

        let walletConfiguration = walletConfigurationStore.configurations[indexPath.row]
        connectWallet(walletConfiguration)
    }
}

extension ManageWalletsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return walletConfigurationStore.configurations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ManageWalletTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
        cell.configure(walletConfigurationStore.configurations[indexPath.row])
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        walletConfigurationStore.removeWallet(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}

extension ManageWalletsViewController: ManageWalletTableViewCellDelegate {
    func presentBackupViewController(for walletConfiguration: WalletConfiguration) {
        let viewController = ChannelBackupViewController(walletConfiguration: walletConfiguration)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
