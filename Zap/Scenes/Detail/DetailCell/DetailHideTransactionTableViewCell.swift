//
//  Zap
//
//  Created by Otto Suess on 06.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class DetailHideTransactionTableViewCell: UITableViewCell {
    @IBOutlet private weak var hideTransactionButton: UIButton!
    
    var hideAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        hideTransactionButton.setTitle("delete", for: .normal)
        
        Style.button.apply(to: hideTransactionButton) {
            $0.tintColor = UIColor.zap.tomato
        }
    }
    
    @IBAction private func hideTransaction(_ sender: Any) {
        hideAction?()

    }
}
