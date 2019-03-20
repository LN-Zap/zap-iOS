//
//  Library
//
//  Created by 0 on 20.03.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import UIKit

class WalletListCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var checkIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        Style.Label.body.apply(to: titleLabel)
        Style.Label.subHeadline.apply(to: subtitleLabel)
        checkIcon.isHidden = true

        backgroundColor = UIColor.Zap.background
    }

    var isSelectedConfiguration: Bool = false {
        didSet {
            checkIcon.isHidden = !isSelectedConfiguration
        }
    }

    var walletConfiguration: WalletConfiguration? {
        didSet {
            titleLabel.text = walletConfiguration?.alias
            subtitleLabel.text = walletConfiguration?.network?.localized
        }
    }
}
