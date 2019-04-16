//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Lightning
import UIKit

enum ChannelBalanceColor {
    static var local = UIColor.Zap.lightningOrange
    static var remote = UIColor.Zap.lightningBlue
    static let pending = UIColor.Zap.gray
    static let offline = UIColor.Zap.superRed
}

final class ChannelListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private var headerView: ChannelListHeaderView!

    private var channelListViewModel: ChannelListViewModel! // swiftlint:disable:this implicitly_unwrapped_optional
    private var addChannelButtonTapped: (() -> Void)?
    private var presentChannelDetail: ((UIViewController, ChannelViewModel) -> Void)?

    static func instantiate(channelListViewModel: ChannelListViewModel, addChannelButtonTapped: @escaping () -> Void, presentChannelDetail: @escaping (UIViewController, ChannelViewModel) -> Void) -> UIViewController {
        let viewController = StoryboardScene.ChannelList.channelViewController.instantiate()
        viewController.channelListViewModel = channelListViewModel
        viewController.addChannelButtonTapped = addChannelButtonTapped
        viewController.presentChannelDetail = presentChannelDetail

        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.Zap.background

        tableView.registerCell(ChannelTableViewCell.self)
        tableView.delegate = self
        tableView.backgroundColor = UIColor.Zap.deepSeaBlue
        tableView.rowHeight = 100
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 1))

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentAddChannel))
        navigationItem.largeTitleDisplayMode = .never

        channelListViewModel.dataSource
            .map { "\(L10n.Scene.Channels.title) (\($0.collection.count))" }
            .bind(to: navigationItem.reactive.title)
            .dispose(in: reactive.bag)

        channelListViewModel.dataSource.bind(to: tableView) { [weak self] array, indexPath, tableView in
            let cell: ChannelTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
            let channelViewModel = array[indexPath.row]
            cell.update(channelViewModel: channelViewModel, maxBalance: self?.channelListViewModel?.maxBalance ?? 0)
            return cell
        }

        headerView.setup(for: channelListViewModel)
    }

    @objc private func presentAddChannel() {
        addChannelButtonTapped?()
    }
}

extension ChannelListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let channelViewModel = channelListViewModel?.dataSource[indexPath.row] else { return }
        presentChannelDetail?(self, channelViewModel)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerView.preferredHeight(for: channelListViewModel)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
}
