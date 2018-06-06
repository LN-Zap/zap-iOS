//
//  Zap
//
//  Created by Otto Suess on 05.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation

final class ChannelDetailViewModel: DetailViewModel {
    var detailViewControllerTitle = "scene.channel_detail.title".localized
    var detailCells: MutableObservableArray<DetailCellType>
    
    init(channel: Channel) {
        var cells = [DetailCellType]()
        
        cells.append(.info(DetailTableViewCell.Info(title: "remotePubKey:", data: channel.remotePubKey)))
        
        cells.append(.separator)
        
        cells.append(.balance(DetailBalanceTableViewCell.Info(localBalance: channel.localBalance, remoteBalance: channel.remoteBalance)))
        
        if let localBalance = Settings.primaryCurrency.value.format(satoshis: channel.localBalance) {
            let gradient = [UIColor.zap.lightMustard, UIColor.zap.peach]
            cells.append(.legend(DetailLegendTableViewCell.Info(title: "local Balance:", data: localBalance, gradient: gradient)))
        }
        
        if let remoteBalance = Settings.primaryCurrency.value.format(satoshis: channel.remoteBalance) {
            let gradient = [UIColor.zap.lightGrey, UIColor.zap.lightGrey]
            cells.append(.legend(DetailLegendTableViewCell.Info(title: "remote Balance:", data: remoteBalance, gradient: gradient)))
        }
        
        cells.append(.separator)
        
        cells.append(.info(DetailTableViewCell.Info(title: "update Count:", data: String(describing: channel.updateCount ?? 0))))
        
        let blockHeight = channel.blockHeight
        cells.append(.info(DetailTableViewCell.Info(title: "blockHeight:", data: String(describing: blockHeight))))
        
        detailCells = MutableObservableArray(cells)
    }
}
