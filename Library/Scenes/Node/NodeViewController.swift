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
    // swiftlint:enable implicitly_unwrapped_optional

    static func instantiate(presentChannels: @escaping (() -> Void), presentSettings: @escaping () -> Void, presentWallet: @escaping (UIPageViewController.NavigationDirection) -> Void) -> NodeViewController {
        let viewController = StoryboardScene.Node.nodeViewController.instantiate()

        viewController.channelListButtonTapped = presentChannels
        viewController.settingsButtonTapped = presentSettings
        viewController.walletButtonTapped = presentWallet

        return viewController
    }

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
    }

    @objc private func presentWallet() {
        walletButtonTapped(.forward)
    }
}

extension NodeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nodeCell", for: indexPath)
        cell.backgroundColor = UIColor.Zap.seaBlue
        cell.accessoryType = .disclosureIndicator

        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Channels"
        case 1:
            cell.textLabel?.text = "Settings"
        default:
            fatalError("missing table index implementation")
        }

        return cell
    }
}

extension NodeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.row {
        case 0:
            channelListButtonTapped()
        case 1:
            settingsButtonTapped()
        default:
            fatalError("missing table index implementation")
        }
    }
}
