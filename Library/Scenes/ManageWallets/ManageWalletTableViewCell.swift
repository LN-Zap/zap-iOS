//
//  Library
//
//  Created by Otto Suess on 04.02.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import UIKit

class ManageWalletTableViewCell: UITableViewCell {
    @IBOutlet private weak var aliasLabel: UILabel!
    @IBOutlet private weak var networkLabel: UILabel!
    @IBOutlet private weak var hostLabel: UILabel!
    @IBOutlet private weak var remoteIndicatorLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = UIColor.Zap.background

        Style.Label.body.apply(to: aliasLabel, remoteIndicatorLabel)
        Style.Label.subHeadline.apply(to: networkLabel, hostLabel)
        hostLabel.textColor = UIColor.Zap.invisibleGray
    }

    func configure(_ walletConfiguration: WalletConfiguration) {
        aliasLabel.text = walletConfiguration.alias ?? "?"
        networkLabel.text = walletConfiguration.network?.localized ?? "?"

        switch walletConfiguration.connection {
        case .local:
            remoteIndicatorLabel.text = "local"
            hostLabel.isHidden = true
        case .remote(let credentials):
            remoteIndicatorLabel.text = "remote"

            let host = credentials.host.absoluteString.prefix { $0 != ":" }
            hostLabel.isHidden = false
            hostLabel.text = "(\(host))"
        }
    }
}
