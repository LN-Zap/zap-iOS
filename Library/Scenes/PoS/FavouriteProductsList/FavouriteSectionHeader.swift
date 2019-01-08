//
//  Library
//
//  Created by Otto Suess on 08.01.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

final class FavouriteSectionHeader: UICollectionReusableView {

    @IBOutlet private weak var headerLabel: UILabel!
    
    func setTitle(_ title: String) {
        headerLabel.text = title
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        headerLabel.textColor = .white
        headerLabel.font = UIFont.Zap.bold.withSize(34)
    }
}
