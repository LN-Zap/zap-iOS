//
//  Zap
//
//  Created by Otto Suess on 18.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

enum DetailCellType {
    case balance(DetailBalanceTableViewCell.Info)
    case channelActions(DetailChannelActionsTableViewCell.Info)
    case hideTransaction
    case info(DetailTableViewCell.Info)
    case legend(DetailLegendTableViewCell.Info)
    case memo(DetailMemoTableViewCell.Info)
    case qrCode(String)
    case separator
    case timer(DetailTimerTableViewCell.Info)
}

protocol DetailCellDelegate: class {
    func dismiss()
    func presentSafariViewController(for url: URL)
}
