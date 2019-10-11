//
//  Library
//
//  Created by 0 on 07.10.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Lightning

final class NodeViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private var nodeHeaderView: NodeHeaderView! {
        didSet {
            nodeHeaderView.delegate = self
        }
    }
    
    // swiftlint:disable implicitly_unwrapped_optional
    private var channelListButtonTapped: (() -> Void)!
    private var settingsButtonTapped: (() -> Void)!
    private var walletButtonTapped: ((UIPageViewController.NavigationDirection) -> Void)!
    private var manageNodes: (() -> Void)!
    private var channelBackupButtonTapped: (() -> Void)!
    private var lightningService: LightningService!
    // swiftlint:enable implicitly_unwrapped_optional

    static func instantiate(
        lightningService: LightningService,
        presentChannels: @escaping (() -> Void),
        presentSettings: @escaping () -> Void,
        presentWallet: @escaping (UIPageViewController.NavigationDirection) -> Void,
        manageNodes: @escaping () -> Void,
        presentChannelBackup: @escaping () -> Void
    ) -> NodeViewController {
        let viewController = StoryboardScene.Node.nodeViewController.instantiate()

        viewController.lightningService = lightningService
        viewController.channelListButtonTapped = presentChannels
        viewController.settingsButtonTapped = presentSettings
        viewController.walletButtonTapped = presentWallet
        viewController.manageNodes = manageNodes
        viewController.channelBackupButtonTapped = presentChannelBackup

        return viewController
    }

    private var content = [[(configure: (UITableViewCell) -> Void, action: () -> Void)]]()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.Scene.MyNode.title

        navigationController?.navigationBar.prefersLargeTitles = false
        
        tableView.dataSource = self
        tableView.delegate = self

        tableView.backgroundColor = UIColor.Zap.background
        tableView.separatorColor = UIColor.Zap.gray
        tableView.rowHeight = 76

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "nodeCell")

        tableView.tableHeaderView = nodeHeaderView
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Asset.arrowRight.image, style: .plain, target: self, action: #selector(presentWallet))

        nodeHeaderView.update(infoService: lightningService.infoService)
        
        content = [
            [
                (configure: {
                    $0.textLabel?.text = L10n.Scene.Channels.title
                    $0.accessoryType = .disclosureIndicator
                    $0.imageView?.image = Asset.nodeChannels.image
                }, action: channelListButtonTapped),
                (configure: {
                    $0.textLabel?.text = L10n.Scene.Settings.Item.channelBackup
                    $0.accessoryType = .disclosureIndicator
                    $0.imageView?.image = Asset.nodeBackup.image
                }, action: channelBackupButtonTapped)
            ],
            [
                (configure: {
                    $0.textLabel?.text = L10n.Scene.Settings.title
                    $0.accessoryType = .disclosureIndicator
                    $0.imageView?.image = Asset.nodeSettings.image
                }, action: settingsButtonTapped)
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
        cell.textLabel?.textColor = UIColor.Zap.white
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

extension NodeViewController: NodeHeaderViewDelegate {
    func manageNodesButtonTapped() {
        self.manageNodes()
    }
}
