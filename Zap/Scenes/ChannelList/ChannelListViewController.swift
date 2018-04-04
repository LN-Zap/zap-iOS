//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import UIKit

struct ChannelBond: TableViewBond {
    func cellForRow(at indexPath: IndexPath, tableView: UITableView, dataSource: Observable2DArray<String, Channel>) -> UITableViewCell {
        let cell: ChannelTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
        cell.channel = dataSource.item(at: indexPath)
        return cell
    }
    
    func titleForHeader(in section: Int, dataSource: Observable2DArray<String, Channel>) -> String? {
        return dataSource[section].metadata
    }
}

class ChannelListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView?
    
    var viewModel: ViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            channelViewModel = ChannelListViewModel(viewModel: viewModel)
        }
    }
    private var channelViewModel: ChannelListViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "scene.channels.title".localized
        
        guard let tableView = tableView else { return }
        
        tableView.rowHeight = 60
        tableView.registerCell(ChannelTableViewCell.self)
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        channelViewModel?.sections.bind(to: tableView, using: ChannelBond())
        
        tableView.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as? UINavigationController
        
        if let channelDetailViewController = navigationController?.topViewController as? ChannelDetailViewController,
            let channel = sender as? Channel,
            let viewModel = viewModel {
            channelDetailViewController.channelViewModel = ChannelDetailViewModel(viewModel: viewModel, channel: channel)
        } else if let openChannelViewController = navigationController?.topViewController as? OpenChannelViewController {
            openChannelViewController.channelViewModel = channelViewModel
        }
    }
    
    @objc
    func refresh(sender: UIRefreshControl) {
        print("refresh")
        sender.endRefreshing()
    }
}

extension ChannelListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView = SectionHeaderView.instanceFromNib
        sectionHeaderView.title = channelViewModel?.sections[section].metadata
        sectionHeaderView.backgroundColor = .white
        return sectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let channel = channelViewModel?.sections.item(at: indexPath)
        performSegue(withIdentifier: "showChannelDetailViewController", sender: channel)
    }
}
