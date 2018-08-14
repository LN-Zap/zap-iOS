//
//  Zap
//
//  Created by Otto Suess on 16.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class MnemonicWordTableViewCell: UITableViewCell {
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var wordLabel: UILabel!

    var index: Int? {
        didSet {
            guard let index = index else { return }
            indexLabel.text = String(index + 1)
        }
    }
    
    var word: String? {
        didSet {
            wordLabel.text = word
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        Style.Label.custom(fontSize: 24).apply(to: indexLabel, wordLabel)
        
        indexLabel.textColor = UIColor.zap.lightGrey
        wordLabel.textColor = .white
    }
}
