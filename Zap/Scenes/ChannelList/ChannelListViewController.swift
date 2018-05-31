//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import UIKit

final class ChannelBond: TableViewBinder<Observable2DArray<String, ChannelViewModel>> {
    override func cellForRow(at indexPath: IndexPath, tableView: UITableView, dataSource: Observable2DArray<String, ChannelViewModel>) -> UITableViewCell {
        let cell: ChannelTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
        cell.channelViewModel = dataSource.item(at: indexPath)
        return cell
    }
    
    func titleForHeader(in section: Int, dataSource: Observable2DArray<String, ChannelViewModel>) -> String? {
        return dataSource[section].metadata
    }
}

class ChannelListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView?
    @IBOutlet private weak var searchBackgroundView: UIView!
    @IBOutlet private weak var searchBar: UISearchBar!
    
    var viewModel: ViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            channelListViewModel = ChannelListViewModel(viewModel: viewModel)
        }
    }
    private var channelListViewModel: ChannelListViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "scene.channels.title".localized
        
        guard let tableView = tableView else { return }
        
        tableView.rowHeight = 60
        tableView.registerCell(ChannelTableViewCell.self)
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        searchBar.placeholder = "search"
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        searchBackgroundView.backgroundColor = UIColor.zap.searchBackground
        
        channelListViewModel?.sections
            .bind(to: tableView, using: ChannelBond())
            .dispose(in: reactive.bag)
        
        tableView.delegate = self
    }
    
    @objc
    func refresh(sender: UIRefreshControl) {
        viewModel?.channels.update()
        sender.endRefreshing()
    }
    
    @IBAction private func presentAddChannel(_ sender: Any) {
        guard let viewModel = viewModel else { fatalError("viewModel not set") }
        let viewController = UIStoryboard.instantiateQRCodeScannerViewController(with: viewModel, strategy: OpenChannelQRCodeScannerStrategy())
        present(viewController, animated: true, completion: nil)
    }
}

extension ChannelListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // TODO: search
        print(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension ChannelListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView = SectionHeaderView.instanceFromNib
        sectionHeaderView.title = channelListViewModel?.sections[section].metadata
        sectionHeaderView.backgroundColor = .white
        return sectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let channelListViewModel = channelListViewModel else { return 0 }
        
        if channelListViewModel.sections.sections.count > 1 {
            return 60
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard
            let viewModel = viewModel,
            let channelViewModel = channelListViewModel?.sections.item(at: indexPath)
            else { return }
        
        let viewController = UIStoryboard.instantiateChannelDetailViewController(with: viewModel, channelViewModel: channelViewModel)
        present(viewController, animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}
