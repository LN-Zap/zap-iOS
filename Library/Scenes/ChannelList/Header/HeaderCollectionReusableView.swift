//
//  Library
//
//  Created by Otto Suess on 29.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

protocol ChannelListHeaderDelegate: class {
    func openChannelButtonTapped()
}

class HeaderCollectionReusableView: UICollectionReusableView {
    static let kind = "HeaderCollectionReusableView"

    @IBOutlet private weak var titleLabel: UILabel!

    weak var delegate: ChannelListHeaderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.font = UIFont.Zap.light.withSize(30)
        titleLabel.textColor = .white
        titleLabel.text = "Network"
    }
    
    @IBAction private func openChannel(_ sender: Any) {
        delegate?.openChannelButtonTapped()
    }
}
