//
//  Library
//
//  Created by 0 on 07.10.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

final class NodeViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    // swiftlint:disable implicitly_unwrapped_optional
    private var channelListButtonTapped: (() -> Void)!
    private var settingsButtonTapped: (() -> Void)!
    private var walletButtonTapped: ((UIPageViewController.NavigationDirection) -> Void)!
    private var disconnectButtonTapped: (() -> Void)!
    // swiftlint:enable implicitly_unwrapped_optional

    static func instantiate(
        presentChannels: @escaping (() -> Void),
        presentSettings: @escaping () -> Void,
        presentWallet: @escaping (UIPageViewController.NavigationDirection) -> Void,
        disconnectWallet: @escaping () -> Void
    ) -> NodeViewController {
        let viewController = StoryboardScene.Node.nodeViewController.instantiate()

        viewController.channelListButtonTapped = presentChannels
        viewController.settingsButtonTapped = presentSettings
        viewController.walletButtonTapped = presentWallet
        viewController.disconnectButtonTapped = disconnectWallet

        return viewController
    }

    private var content = [[(configure: (UITableViewCell) -> Void, action: () -> Void)]]()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "My Node"

        tableView.dataSource = self
        tableView.delegate = self

        tableView.backgroundColor = UIColor.Zap.background
        tableView.separatorColor = UIColor.Zap.gray
        tableView.rowHeight = 76

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "nodeCell")

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Asset.arrowRight.image, style: .plain, target: self, action: #selector(presentWallet))

        content = [
            [
                (configure: {
                    $0.textLabel?.text = "Channels"
                    $0.accessoryType = .disclosureIndicator
                }, action: channelListButtonTapped),
                (configure: {
                    $0.textLabel?.text = "Settings"
                    $0.accessoryType = .disclosureIndicator
                }, action: settingsButtonTapped)
            ],
            [
                (configure: {
                    $0.textLabel?.text = L10n.Scene.Settings.Item.removeRemoteNode
                }, action: disconnectButtonTapped)
            ]
        ]
    }

    @objc private func presentWallet() {
        walletButtonTapped(.forward)
    }
}

extension NodeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        content.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nodeCell", for: indexPath)
        cell.backgroundColor = UIColor.Zap.seaBlue

        let (configure, _) = content[indexPath.section][indexPath.row]
        configure(cell)
        return cell
    }
}

extension NodeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let (_, action) = content[indexPath.section][indexPath.row]
        action()
    }
}
