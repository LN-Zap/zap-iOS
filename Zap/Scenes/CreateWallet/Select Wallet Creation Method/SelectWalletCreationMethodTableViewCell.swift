//
//  Zap
//
//  Created by Otto Suess on 22.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class SelectWalletCreationMethodTableViewCell: UITableViewCell {

    @IBOutlet private weak var mainLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    func set(title: String, description: String) {
        mainLabel.text = title
        descriptionLabel.text = description
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        
        accessoryType = .disclosureIndicator

        Style.label.apply(to: mainLabel) {
            $0.textColor = .white
            $0.font = $0.font.withSize(36)
        }
        Style.label.apply(to: descriptionLabel) {
            $0.textColor = .white
            $0.font = $0.font.withSize(18)
        }
    }
}
