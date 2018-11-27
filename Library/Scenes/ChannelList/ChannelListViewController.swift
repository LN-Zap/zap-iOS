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
        addChannelButtonTapped: @escaping () -> Void,
        presentChannelDetail: @escaping (UIViewController, ChannelViewModel) -> Void) -> UIViewController {
        let viewController = Storyboard.channelList.initial(viewController: ChannelListViewController.self)
        
        viewController.channelListViewModel = channelListViewModel
        viewController.addChannelButtonTapped = addChannelButtonTapped
        viewController.presentChannelDetail = presentChannelDetail
        
        return viewController
    }
}

final class ChannelListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    fileprivate var channelListViewModel: ChannelListViewModel?
    fileprivate var addChannelButtonTapped: (() -> Void)?
    fileprivate var presentChannelDetail: ((UIViewController, ChannelViewModel) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.Scene.Channels.title
        view.backgroundColor = UIColor.Zap.background

        tableView.registerCell(ChannelTableViewCell.self)
        tableView.delegate = self
        tableView.backgroundColor = UIColor.Zap.deepSeaBlue
        tableView.rowHeight = 76
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentAddChannel))
        navigationItem.largeTitleDisplayMode = .never
        
        channelListViewModel?.dataSource.bind(to: tableView) { [weak self] array, indexPath, tableView in
            let cell: ChannelTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
            let channelViewModel = array[indexPath.row]
            cell.update(channelViewModel: channelViewModel, maxChannelCapacity: self?.channelListViewModel?.maxChannelCapacity ?? 1)
            return cell
        }
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
}
