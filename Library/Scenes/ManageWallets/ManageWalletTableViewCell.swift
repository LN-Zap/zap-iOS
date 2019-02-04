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
    @IBOutlet private weak var remoteIndicatorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = UIColor.Zap.background
        
        Style.Label.body.apply(to: [aliasLabel, remoteIndicatorLabel])
        Style.Label.subHeadline.apply(to: networkLabel)
    }
    
    func configure(_ walletConfiguration: WalletConfiguration) {
        aliasLabel.text = walletConfiguration.alias ?? "?"
        networkLabel.text = walletConfiguration.network?.localized ?? "?"
        
        switch walletConfiguration.connection {
        #if !REMOTEONLY
        case .local:
            remoteIndicatorLabel.text = "local"
        #endif
        case .remote:
            remoteIndicatorLabel.text = "remote"
        }
    }
}
