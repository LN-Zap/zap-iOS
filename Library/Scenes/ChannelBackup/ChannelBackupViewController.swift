//
//  Library
//
//  Created by 0 on 12.04.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Logger

final class ChannelBackupViewController: UITableViewController {
    private let walletConfiguration: WalletConfiguration

    private var channelBackupURL: URL? {
        guard let nodePubKey = walletConfiguration.nodePubKey else { return nil }
        return FileManager.default.channelBackupDirectory(for: nodePubKey)?.appendingPathComponent("channel.backup")
    }

    private var channelBackupFile: Data? {
        guard let url = channelBackupURL else { return nil }
        return try? Data(contentsOf: url)
    }

    init(walletConfiguration: WalletConfiguration) {
        self.walletConfiguration = walletConfiguration
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.Scene.ChannelBackup.title

        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = UIColor.Zap.deepSeaBlue
        tableView.separatorColor = UIColor.Zap.gray
        tableView.estimatedRowHeight = 300
        tableView.registerCell(CertificateDetailCell.self)
        tableView.allowsSelection = false

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareChannelBackup))
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return L10n.Scene.ChannelBackup.cellTitle(walletConfiguration.alias ?? "?")
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CertificateDetailCell = tableView.dequeueCellForIndexPath(indexPath)
        cell.descriptionText = channelBackupFile?.hexadecimalString ?? L10n.Scene.ChannelBackup.notFound
        cell.contentView.backgroundColor = UIColor.Zap.seaBlue
        cell.numberOfLines = 10
        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let view = view as? UITableViewHeaderFooterView else { return }
        view.textLabel?.text = view.textLabel?.text?.capitalized
    }

    @objc private func shareChannelBackup() {
        guard let channelBackupURL = channelBackupURL else { return }

        let items: [Any] = [channelBackupURL]

        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
}
