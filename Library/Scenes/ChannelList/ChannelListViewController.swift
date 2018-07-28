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
        closeButtonTapped: @escaping (Channel, String, @escaping () -> Void) -> Void,
        addChannelButtonTapped: @escaping () -> Void) -> UIViewController {
        let viewController = Storyboard.channelList.initial(viewController: ChannelListViewController.self)
        
        viewController.channelListViewModel = channelListViewModel
        viewController.closeButtonTapped = closeButtonTapped
        viewController.addChannelButtonTapped = addChannelButtonTapped

        viewController.tabBarItem.title = "Channels"
        viewController.tabBarItem.image = UIImage(named: "tabbar_wallet", in: Bundle.library, compatibleWith: nil)
        
        return viewController
    }
}

final class ChannelListViewController: UIViewController {
    @IBOutlet private weak var backgroundGradientView: GradientView! {
        didSet {
            backgroundGradientView.direction = .vertical
            backgroundGradientView.gradient = [UIColor.zap.backgroundGradientTop, UIColor.zap.backgroundGradientBottom]
        }
    }
    @IBOutlet private weak var collectionView: UICollectionView!
    
    fileprivate var addChannelButtonTapped: (() -> Void)?
    fileprivate var closeButtonTapped: ((Channel, String, @escaping () -> Void) -> Void)?
    fileprivate var channelListViewModel: ChannelListViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.registerCell(ChannelCell.self)
        
        channelListViewModel?.dataSource.bind(to: collectionView) { (dataSource, indexPath, collectionView) -> UICollectionViewCell in
            let channelCell: ChannelCell = collectionView.dequeueCellForIndexPath(indexPath)
            channelCell.channelViewModel = dataSource[indexPath.item]
            return channelCell
        }
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
