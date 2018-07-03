//
//  Zap
//
//  Created by Otto Suess on 05.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation
import Lightning

final class ChannelDetailViewModel: DetailViewModel {
    private let channel: Channel
    private let channelListViewModel: ChannelListViewModel
    
    var detailViewControllerTitle = "scene.channel_detail.title".localized
    var detailCells: MutableObservableArray<DetailCellType>
    
    init(channel: Channel, infoService: InfoService, channelListViewModel: ChannelListViewModel) {
        self.channel = channel
        self.channelListViewModel = channelListViewModel
        
        detailCells = MutableObservableArray([])

        detailCells.append(.info(DetailTableViewCell.Info(title: "scene.channel_detail.remote_pub_key_label".localized, data: channel.remotePubKey)))
        detailCells.append(.separator)
        
        detailCells.append(.balance(DetailBalanceTableViewCell.Info(localBalance: channel.localBalance, remoteBalance: channel.remoteBalance)))
        
        if let localBalance = Settings.shared.primaryCurrency.value.format(satoshis: channel.localBalance) {
            let gradient = [UIColor.zap.lightMustard, UIColor.zap.peach]
            detailCells.append(.legend(DetailLegendTableViewCell.Info(title: "scene.channel_detail.local_balance_label".localized, data: localBalance, gradient: gradient)))
        }
        
        if let remoteBalance = Settings.shared.primaryCurrency.value.format(satoshis: channel.remoteBalance) {
            let gradient = [UIColor.zap.lightGrey, UIColor.zap.lightGrey]
            detailCells.append(.legend(DetailLegendTableViewCell.Info(title: "scene.channel_detail.remote_balance_label".localized, data: remoteBalance, gradient: gradient)))
        }
        detailCells.append(.separator)
        
        detailCells.append(.info(DetailTableViewCell.Info(title: "scene.channel_detail.update_count_label".localized, data: String(describing: channel.updateCount ?? 0))))
        detailCells.append(.separator)
        
        let blockHeight = channel.blockHeight
        detailCells.append(.info(DetailTableViewCell.Info(title: "scene.channel_detail.block_height_label".localized, data: String(describing: blockHeight))))
        detailCells.append(.separator)
        
        if let cell = DetailCellType.blockExplorerCell(txid: channel.channelPoint.fundingTxid, title: "scene.channel_detail.funding_transaction_label".localized, network: infoService.network.value) {
            detailCells.append(cell)
        }
        
        if !channel.state.isClosing {
            let closeTitle = channel.state == .active ? "scene.channel_detail.close_button".localized : "scene.channel_detail.force_close_button".localized
            detailCells.append(.destructiveAction(DetailDestructiveActionTableViewCell.Info(title: closeTitle, type: .closeChannel(channel, channel.remotePubKey), action: closeChannel)))
        }
    }
    
    private func closeChannel() {
        channelListViewModel.close(channel)
    }
}
