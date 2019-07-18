//
//  Library
//
//  Created by Otto Suess on 04.02.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import UIKit

protocol ManageWalletTableViewCellDelegate: class {
    func presentBackupViewController(for walletConfiguration: WalletConfiguration)
}

class ManageWalletTableViewCell: UITableViewCell {
    @IBOutlet private weak var aliasLabel: UILabel!
    @IBOutlet private weak var networkLabel: UILabel!
    @IBOutlet private weak var hostLabel: UILabel!

    private var walletConfiguration: WalletConfiguration?
    weak var delegate: ManageWalletTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = UIColor.Zap.background

        Style.Label.body.apply(to: aliasLabel)
        Style.Label.subHeadline.apply(to: networkLabel, hostLabel)
        hostLabel.textColor = UIColor.Zap.invisibleGray
    }

    func configure(_ walletConfiguration: WalletConfiguration) {
        self.walletConfiguration = walletConfiguration

        aliasLabel.text = walletConfiguration.alias
        networkLabel.text = walletConfiguration.network.localized

        switch walletConfiguration.connection {
        case .local:
            hostLabel.text = "local"
        case .remote(let credentials):
            let host = credentials.host.absoluteString.prefix { $0 != ":" }
            hostLabel.isHidden = false
            hostLabel.text = "(\(host))"
        }
    }

    @IBAction private func backupButtonTapped(_ sender: Any) {
        guard let walletConfiguration = walletConfiguration else { return }
        delegate?.presentBackupViewController(for: walletConfiguration)
    }
}
