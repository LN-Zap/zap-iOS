//
//  Zap
//
//  Created by Otto Suess on 22.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class SelectWalletCreationMethodTableViewCell: UITableViewCell {

    @IBOutlet private weak var mainLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!

    func set(title: String, description: String) {
        mainLabel.text = title
        descriptionLabel.text = description
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = UIColor.Zap.seaBlue

        accessoryType = .disclosureIndicator

        Style.Label.custom(fontSize: 36).apply(to: mainLabel)
        Style.Label.custom(fontSize: 18).apply(to: descriptionLabel)
    }
}
