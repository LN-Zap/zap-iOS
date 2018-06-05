//
//  Zap
//
//  Created by Otto Suess on 05.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation

final class ChannelViewModel: DetailViewModel {
    var detailViewControllerTitle = "scene.channel_detail.title".localized
    var detailCells = MutableObservableArray<DetailCellType>([])
    
    let channel: Channel
    
    let state: Observable<ChannelState>
    let name: Observable<String>
    
    init(channel: Channel, viewModel: ViewModel) {
        self.channel = channel
        
        name = Observable(channel.remotePubKey)
        state = Observable(channel.state)

        viewModel.aliasStore.alias(for: channel.remotePubKey) { [name] in
            name.value = $0
        }
        
        setupInfoArray()
    }
    
    private func setupInfoArray() {
        detailCells.append(.info(DetailTableViewCell.Info(title: "remotePubKey:", data: channel.remotePubKey)))

        detailCells.append(.separator)
        
        detailCells.append(.balance(DetailBalanceTableViewCell.Info(localBalance: channel.localBalance, remoteBalance: channel.remoteBalance)))

        if let localBalance = Settings.primaryCurrency.value.format(satoshis: channel.localBalance) {
            let gradient = [UIColor.zap.lightMustard, UIColor.zap.peach]
            detailCells.append(.legend(DetailLegendTableViewCell.Info(title: "local Balance:", data: localBalance, gradient: gradient)))
        }
        
        if let remoteBalance = Settings.primaryCurrency.value.format(satoshis: channel.remoteBalance) {
            let gradient = [UIColor.zap.lightGrey, UIColor.zap.lightGrey]
            detailCells.append(.legend(DetailLegendTableViewCell.Info(title: "remote Balance:", data: remoteBalance, gradient: gradient)))
        }
        
        detailCells.append(.separator)

        detailCells.append(.info(DetailTableViewCell.Info(title: "update Count:", data: String(describing: channel.updateCount ?? 0))))

        let blockHeight = channel.blockHeight
        detailCells.append(.info(DetailTableViewCell.Info(title: "blockHeight:", data: String(describing: blockHeight))))
    }
}

extension ChannelViewModel: Equatable {
    static func == (lhs: ChannelViewModel, rhs: ChannelViewModel) -> Bool {
        return lhs.channel == rhs.channel
    }
}
