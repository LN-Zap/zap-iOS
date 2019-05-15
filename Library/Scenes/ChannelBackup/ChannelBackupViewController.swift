//
//  Library
//
//  Created by 0 on 12.04.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Logger

final class ChannelBackupViewController: UIViewController {
    @IBOutlet private weak var fileNameLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!

    let cellContent: [(String, BackupLogger.Type)] = [
        ("iCloud Drive", ICloudDriveBackupService.self),
        ("Local Backup", LocalDocumentBackupService.self)
    ]

    private var walletConfiguration: WalletConfiguration! // swiftlint:disable:this implicitly_unwrapped_optional

    private var latestDate: Date? {
        return cellContent.compactMap { $0.1.lastBackup }.max()
    }

    private var channelBackupURL: URL? {
        guard let nodePubKey = walletConfiguration.nodePubKey else { return nil }
        return FileManager.default.channelBackupDirectory(for: nodePubKey)?.appendingPathComponent("channel.backup")
    }

    private var channelBackupFile: Data? {
        guard let url = channelBackupURL else { return nil }
        return try? Data(contentsOf: url)
    }

    static func instantiate(walletConfiguration: WalletConfiguration) -> ChannelBackupViewController {
        let viewController = StoryboardScene.ChannelBackup.channelBackupViewController.instantiate()
        viewController.walletConfiguration = walletConfiguration
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.Scene.ChannelBackup.title

        if let latestDate = latestDate {
            dateLabel.text = DateFormatter.localizedString(from: latestDate, dateStyle: .medium, timeStyle: .short)
        } else {
            dateLabel.text = L10n.Scene.ChannelBackup.notFound
        }

        view.backgroundColor = UIColor.Zap.background

        Style.Label.body.apply(to: fileNameLabel)
        Style.Label.subHeadline.apply(to: dateLabel)

        tableView.dataSource = self
        tableView.delegate = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = UIColor.Zap.deepSeaBlue
        tableView.separatorColor = UIColor.Zap.gray
        tableView.rowHeight = 76
        tableView.allowsSelection = false
        tableView.isScrollEnabled = false

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareChannelBackup))
    }

    @objc private func shareChannelBackup() {
        guard let channelBackupURL = channelBackupURL else { return }

        let items: [Any] = [channelBackupURL]

        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
}

extension ChannelBackupViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}

extension ChannelBackupViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellContent.count
    }

    private func createCell() -> UITableViewCell {
        let identifier = "ChannelBackupViewControllerCell"

        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) {
            return cell
        } else {
            return UITableViewCell(style: .default, reuseIdentifier: identifier)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = createCell()

        let (title, backupType) = cellContent[indexPath.row]

        if let label = cell.textLabel {
            Style.Label.body.apply(to: label)
            label.text = title
        }

        if backupType.lastBackup != nil {
            cell.accessoryView = UIImageView(image: Asset.iconCheckGreen.image)
        } else {
            cell.accessoryView = nil
        }

        cell.backgroundColor = UIColor.Zap.seaBlue

        return cell
    }
}
