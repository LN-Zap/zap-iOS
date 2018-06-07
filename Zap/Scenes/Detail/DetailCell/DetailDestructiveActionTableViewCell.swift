//
//  Zap
//
//  Created by Otto Suess on 06.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class DetailDestructiveActionTableViewCell: UITableViewCell {
    struct Info {
        let title: String
        let action: () -> Void
    }
    
    @IBOutlet private weak var destructiveActionButton: UIButton!
    
    weak var delegate: DetailCellDelegate?
    
    var info: DetailDestructiveActionTableViewCell.Info? {
        didSet {
            guard let info = info else { return }
            destructiveActionButton.setTitle(info.title, for: .normal)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        Style.button.apply(to: destructiveActionButton)
        destructiveActionButton.tintColor = UIColor.zap.tomato
    }
    
    @IBAction private func executeAction(_ sender: Any) {
        info?.action()
        delegate?.dismiss()
    }
}
