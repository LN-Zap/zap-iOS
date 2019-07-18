//
//  Library
//
//  Created by 0 on 20.03.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import UIKit

class WalletListActionCell: UITableViewCell {
    @IBOutlet private weak var actionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        actionLabel?.text = L10n.Scene.Settings.Item.removeRemoteNode
        actionLabel?.textColor = UIColor.Zap.lightningOrange
        backgroundColor = UIColor.Zap.background
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
    }
}
