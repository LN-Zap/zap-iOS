//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Lightning
import UIKit

extension UIStoryboard {
    static func instantiateChannelListViewController(
        channelListViewModel: ChannelListViewModel,
        presentChannelDetail: @escaping (ChannelViewModel) -> Void,
        closeButtonTapped: @escaping (Channel, String, @escaping () -> Void) -> Void,
        addChannelButtonTapped: @escaping () -> Void) -> UINavigationController {
        let viewController = Storyboard.channelList.initial(viewController: ChannelListViewController.self)
        
        viewController.channelListViewModel = channelListViewModel
        viewController.presentChannelDetail = presentChannelDetail
        viewController.closeButtonTapped = closeButtonTapped
        viewController.addChannelButtonTapped = addChannelButtonTapped
        
        let navigationController = ZapNavigationController(rootViewController: viewController)
        navigationController.tabBarItem.title = "Channels"
        navigationController.tabBarItem.image = UIImage(named: "tabbar_wallet", in: Bundle.library, compatibleWith: nil)

        return navigationController
    }
}

final class ChannelListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView?
    
    fileprivate var presentChannelDetail: ((ChannelViewModel) -> Void)?
    fileprivate var addChannelButtonTapped: (() -> Void)?
    fileprivate var closeButtonTapped: ((Channel, String, @escaping () -> Void) -> Void)?
    fileprivate var channelListViewModel: ChannelListViewModel?
    
    deinit {
        tableView?.isEditing = false // fixes Bond bug. Binding is not released in editing mode.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "scene.channels.title".localized
        
        guard let tableView = tableView else { return }
        
        tableView.rowHeight = 60
        tableView.registerCell(ChannelTableViewCell.self)
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        channelListViewModel?.dataSource
            .bind(to: tableView) { dataSource, indexPath, tableView in
                let cell: ChannelTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
                cell.channelViewModel = dataSource[indexPath]
                return cell
            }
            .dispose(in: reactive.bag)
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        channelListViewModel?.refresh()
        sender.endRefreshing()
    }
    
    @IBAction private func presentAddChannel(_ sender: Any) {
        addChannelButtonTapped?()
    }
    
    func closeChannel(for channelViewModel: ChannelViewModel) {
        closeButtonTapped?(channelViewModel.channel, channelViewModel.name.value) { [weak self] in
            self?.channelListViewModel?.close(channelViewModel.channel) { result in
                if let error = result.error {
                    self?.parent?.presentErrorToast(error.localizedDescription)
                } else {
                    self?.parent?.presentSuccessToast("scene.channels.close_success.toast".localized)
                }
            }
        }
    }
}

extension ChannelListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension ChannelListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView = SectionHeaderView.instanceFromNib
        sectionHeaderView.title = channelListViewModel?.dataSource[section].metadata
        sectionHeaderView.backgroundColor = .white
        return sectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let channelListViewModel = channelListViewModel else { return 0 }
        
        if channelListViewModel.dataSource.sections.count > 1 {
            return 60
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard
            let channelViewModel = channelListViewModel?.dataSource.item(at: indexPath)
            else { return }
        
        presentChannelDetail?(channelViewModel)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard
            let channelViewModel = channelListViewModel?.dataSource.item(at: indexPath),
            !channelViewModel.state.value.isClosing
            else { return [] }
        
        let closeTitle = channelViewModel.channel.state == .active ? "scene.channel_detail.close_button".localized : "scene.channel_detail.force_close_button".localized

        let closeAction = UITableViewRowAction(style: .destructive, title: closeTitle) { [weak self] _, _ in
            self?.closeChannel(for: channelViewModel)
        }
        closeAction.backgroundColor = UIColor.zap.tomato
        return [closeAction]
    }
}
