//
//  Library
//
//  Created by Otto Suess on 19.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

final class CertificateDetailCell: UITableViewCell {
    @IBOutlet private weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        descriptionLabel.font = UIFont(name: "Courier", size: 13)
    }

    var descriptionText: String? {
        didSet {
            descriptionLabel.text = descriptionText
        }
    }
}
