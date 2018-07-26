//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Lightning
import UIKit
import Wallet

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
    @IBOutlet private weak var walletView: WalletView!
    @IBOutlet private weak var walletHeaderView: UIView!
    @IBOutlet private weak var headerLabel: UILabel!
    
    fileprivate var addChannelButtonTapped: (() -> Void)?
    fileprivate var closeButtonTapped: ((Channel, String, @escaping () -> Void) -> Void)?
    fileprivate var channelListViewModel: ChannelListViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerLabel.font = UIFont.zap.light.withSize(40)
        headerLabel.text = "scene.channels.title".localized
        
        walletView.walletHeader = walletHeaderView
        walletView.minimalDistanceBetweenStackedCardViews = 50
        walletView.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)
        guard let channels = channelListViewModel?.dataSource.array else { fatalError("view model not set") }

        var coloredCardViews = [ChannelDetailView]()
        
        for channel in channels {
            let cardView = ChannelDetailView.nibForClass()
            cardView.channelViewModel = channel
            coloredCardViews.append(cardView)
        }
        walletView.reload(cardViews: coloredCardViews)
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
