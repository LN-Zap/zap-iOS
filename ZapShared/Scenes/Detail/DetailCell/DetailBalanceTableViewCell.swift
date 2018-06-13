//
//  Zap
//
//  Created by Otto Suess on 05.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import UIKit

final class DetailBalanceTableViewCell: UITableViewCell {
    struct Info {
        let localBalance: Satoshi
        let remoteBalance: Satoshi
    }
    
    @IBOutlet private weak var balanceView: BalanceView!
    
    var info: Info? {
        didSet {
            guard let info = info else { return }
            balanceView.set(localBalance: info.localBalance, remoteBalance: info.remoteBalance)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
}
