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
        closeButtonTapped: @escaping (ChannelViewModel, @escaping () -> Void) -> Void,
        addChannelButtonTapped: @escaping () -> Void,
        blockExplorerButtonTapped: @escaping (String, BlockExplorer.CodeType) -> Void) -> UIViewController {
        let viewController = Storyboard.channelList.initial(viewController: ChannelListViewController.self)
        
        viewController.channelListViewModel = channelListViewModel
        viewController.closeButtonTapped = closeButtonTapped
        viewController.addChannelButtonTapped = addChannelButtonTapped
        viewController.blockExplorerButtonTapped = blockExplorerButtonTapped
        
        viewController.tabBarItem.title = "scene.channels.title".localized
        
        return viewController
    }
}

final class ChannelListViewController: UIViewController {
    @IBOutlet private weak var collectionView: ChannelCollectionView!
    
    fileprivate var channelListViewModel: ChannelListViewModel?
    
    fileprivate var addChannelButtonTapped: (() -> Void)?
    fileprivate var closeButtonTapped: ((ChannelViewModel, @escaping () -> Void) -> Void)?
    fileprivate var blockExplorerButtonTapped: ((String, BlockExplorer.CodeType) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "scene.channels.title".localized
        view.backgroundColor = UIColor.Zap.background

        collectionView.registerCell(ChannelCell.self)
        
        channelListViewModel?.dataSource.observeNext { [weak self] _ in
            self?.collectionView.reloadData()
        }.dispose(in: reactive.bag)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentAddChannel))
        navigationItem.largeTitleDisplayMode = .never
        
        collectionView.dataSource = self
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        channelListViewModel?.refresh()
        sender.endRefreshing()
    }
    
    @objc private func presentAddChannel() {
        addChannelButtonTapped?()
    }
    
    func closeChannel(for channelViewModel: ChannelViewModel) {
        closeButtonTapped?(channelViewModel) { [weak self] in
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

extension ChannelListViewController: ChannelListDataSource {
    func heightForItem(at index: Int) -> CGFloat {
        guard let elements = channelListViewModel?.dataSource[index].detailViewModel.elements else { return 0 }
        
        return elements.height(spacing: 14) + 2 * 14
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return channelListViewModel?.dataSource.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let channelCell: ChannelCell = collectionView.dequeueCellForIndexPath(indexPath)
        channelCell.channelViewModel = channelListViewModel?.dataSource[indexPath.item]
        channelCell.delegate = self
        return channelCell
    }
}

extension ChannelListViewController: ChannelCellDelegate {
    func closeChannelButtonTapped(channelViewModel: ChannelViewModel) {
        closeButtonTapped?(channelViewModel) { [weak self] in
            let loadingView = self?.presentLoadingView(text: "Closing Channel")
            self?.view.isUserInteractionEnabled = false
            self?.channelListViewModel?.close(channelViewModel.channel) { _ in
                DispatchQueue.main.async {
                    self?.view.isUserInteractionEnabled = true
                    self?.collectionView.switchToStackView()
                    loadingView?.dismiss()
                }
            }
        }
    }
    
    func fundingTransactionTxIdButtonTapped(channelViewModel: ChannelViewModel) {
        blockExplorerButtonTapped?(channelViewModel.channel.channelPoint.fundingTxid, .transactionId)
    }
}
