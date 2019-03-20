//
//  Library
//
//  Created by Otto Suess on 13.02.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import UIKit

final class WalletListViewController: UIViewController {
    // swiftlint:disable implicitly_unwrapped_optional
    private var walletConfigurationStore: WalletConfigurationStore!
    // swiftlint:enable implicitly_unwrapped_optional
    private weak var disconnectWalletDelegate: DisconnectWalletDelegate?

    @IBOutlet private weak var tableView: UITableView!

    static func instantiate(walletConfigurationStore: WalletConfigurationStore, disconnectWalletDelegate: DisconnectWalletDelegate) -> WalletListViewController {
        let viewController = StoryboardScene.WalletList.walletListViewController.instantiate()
        viewController.walletConfigurationStore = walletConfigurationStore
        viewController.disconnectWalletDelegate = disconnectWalletDelegate
        return viewController
    }

    private let rowHeight: CGFloat = 76
    private let manageWalletRowHeight: CGFloat = 44

    var preferredHeight: CGFloat {
        let navigationBarHeight: CGFloat = 44
        let bottomSpacing: CGFloat = 32
        return CGFloat(walletConfigurationStore.configurations.count) * rowHeight + navigationBarHeight + bottomSpacing + manageWalletRowHeight
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.Scene.WalletList.title

        navigationItem.leftBarButtonItem = editButtonItem

        tableView.rowHeight = rowHeight
        tableView.backgroundColor = UIColor.Zap.background
        tableView.separatorColor = UIColor.Zap.gray
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.registerCell(WalletListCell.self)
        tableView.registerCell(WalletListActionCell.self)
    }

    private func isSelectedConfiguration(_ configuration: WalletConfiguration) -> Bool {
        return configuration == walletConfigurationStore.selectedWallet
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: true)
    }

    @IBAction private func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension WalletListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.row < walletConfigurationStore.configurations.count {
            let configuration = walletConfigurationStore.configurations[indexPath.row]
            guard !isSelectedConfiguration(configuration) else { return }

            disconnectWalletDelegate?.reconnect(walletConfiguration: configuration)
            dismiss(animated: true, completion: nil)
        } else {
            disconnectWalletDelegate?.disconnect()
            dismiss(animated: true, completion: nil)
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        walletConfigurationStore.removeWallet(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)

        if walletConfigurationStore.selectedWallet == nil {
            disconnectWalletDelegate?.disconnect()
            dismiss(animated: true, completion: nil)
        }
    }
}

extension WalletListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row < walletConfigurationStore.configurations.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < walletConfigurationStore.configurations.count {
            return rowHeight
        } else {
            return manageWalletRowHeight
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return walletConfigurationStore.configurations.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < walletConfigurationStore.configurations.count {
            let configuration = walletConfigurationStore.configurations[indexPath.row]

            let cell: WalletListCell = tableView.dequeueCellForIndexPath(indexPath)
            cell.walletConfiguration = configuration
            cell.isSelectedConfiguration = isSelectedConfiguration(configuration)
            return cell
        } else {
            let cell: WalletListActionCell = tableView.dequeueCellForIndexPath(indexPath)
            return cell
        }
    }
}
