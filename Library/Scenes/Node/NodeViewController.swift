//
//  Library
//
//  Created by 0 on 07.10.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Lightning

private final class SubtitleTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

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
    private var walletButtonTapped: (() -> Void)!
    private var manageNodes: (() -> Void)!
    private var channelBackupButtonTapped: (() -> Void)!
    private var lightningService: LightningService!
    private var presentURIViewController: ((UINavigationController) -> Void)!
    // swiftlint:enable implicitly_unwrapped_optional

    // swiftlint:disable:next function_parameter_count
    static func instantiate(
        lightningService: LightningService,
        presentChannels: @escaping () -> Void,
        presentSettings: @escaping () -> Void,
        presentWallet: @escaping () -> Void,
        manageNodes: @escaping () -> Void,
        presentChannelBackup: @escaping () -> Void,
        presentURIViewController: @escaping (UINavigationController) -> Void
    ) -> NodeViewController {
        let viewController = StoryboardScene.Node.nodeViewController.instantiate()

        viewController.lightningService = lightningService
        viewController.channelListButtonTapped = presentChannels
        viewController.settingsButtonTapped = presentSettings
        viewController.walletButtonTapped = presentWallet
        viewController.manageNodes = manageNodes
        viewController.channelBackupButtonTapped = presentChannelBackup
        viewController.presentURIViewController = presentURIViewController
        
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

        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: "nodeCell")

        tableView.tableHeaderView = nodeHeaderView
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Asset.arrowRight.image, style: .plain, target: self, action: #selector(presentWallet))

        nodeHeaderView.update(lightningService: lightningService)
        
        content = [
            [
                (configure: {
                    $0.textLabel?.text = L10n.Scene.MyNode.Channels.title
                    $0.detailTextLabel?.text = L10n.Scene.MyNode.Channels.subtitle
                    $0.imageView?.image = Asset.nodeChannels.image
                }, action: channelListButtonTapped),
                (configure: {
                    $0.textLabel?.text = L10n.Scene.MyNode.ChannelBackup.title
                    $0.detailTextLabel?.text = L10n.Scene.MyNode.ChannelBackup.subtitle
                    $0.imageView?.image = Asset.nodeBackup.image
                }, action: channelBackupButtonTapped),
                (configure: {
                    $0.textLabel?.text = L10n.Scene.MyNode.Settings.title
                    $0.detailTextLabel?.text = L10n.Scene.MyNode.Settings.subtitle
                    $0.imageView?.image = Asset.nodeSettings.image
                }, action: settingsButtonTapped)
            ],
            [
                (configure: {
                    $0.textLabel?.text = L10n.Scene.MyNode.Support.title
                    $0.detailTextLabel?.text = L10n.Scene.MyNode.Support.subtitle
                    $0.imageView?.image = Asset.nodeSupport.image
                }, action: { [weak self] in self?.pushSupportViewController() })
            ]
        ]
        
        if lightningService.infoService.info.value?.uris.isEmpty == false {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: Asset.nodeQrCode.image, style: .plain, target: self, action: #selector(presentWalletURI))
        }
    }
    
    private func pushSupportViewController() {
        let section = Section<SettingsItem>(title: nil, rows: [
            // swiftlint:disable force_unwrapping
            SafariSettingsItem(title: L10n.Scene.Settings.Item.help, url: URL(string: L10n.Link.help)!),
            SafariSettingsItem(title: L10n.Scene.Settings.Item.reportIssue, url: URL(string: L10n.Link.bugReport)!),
            SafariSettingsItem(title: L10n.Scene.Settings.Item.privacyPolicy, url: URL(string: L10n.Link.privacy)!)
            // swiftlint:enable force_unwrapping
        ])
        
        let viewController = GroupedTableViewController(sections: [section])
        viewController.title = L10n.Scene.MyNode.Support.title
        viewController.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc private func presentWallet() {
        walletButtonTapped()
    }
    
    @objc private func presentWalletURI() {
        guard let navigationController = navigationController else { return }
        presentURIViewController(navigationController)
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
        cell.detailTextLabel?.textColor = UIColor.Zap.gray
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 15, weight: .light)
        cell.accessoryType = .disclosureIndicator
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
