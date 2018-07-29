//
//  Library
//
//  Created by Otto Suess on 29.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {
    @IBOutlet private weak var titleLabel: UILabel!

    static let kind = "HeaderCollectionReusableView"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.font = UIFont.zap.light.withSize(30)
        titleLabel.textColor = .white
        titleLabel.text = "Network"
    }
    
}
