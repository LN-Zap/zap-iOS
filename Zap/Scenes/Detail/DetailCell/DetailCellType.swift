//
//  Zap
//
//  Created by Otto Suess on 18.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

enum DetailCellType {
    case qrCode(String)
    case balance(DetailBalanceTableViewCell.Info)
    case info(DetailTableViewCell.Info)
    case legend(DetailLegendTableViewCell.Info)
    case memo(DetailMemoTableViewCell.Info)
    case separator
    case timer(DetailTimerTableViewCell.Info)
}
