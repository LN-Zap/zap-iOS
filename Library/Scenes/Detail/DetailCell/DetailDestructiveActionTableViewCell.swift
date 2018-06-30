//
//  Zap
//
//  Created by Otto Suess on 06.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Lightning
import UIKit

final class DetailDestructiveActionTableViewCell: UITableViewCell {
    struct Info {
        enum DestructiveActionType {
            case closeChannel(Channel, String)
            case archiveTransaction
        }
        
        let title: String
        let type: DestructiveActionType
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
        guard let info = info else { return }
        switch info.type {
        case let .closeChannel(channel, nodeAlias):
            delegate?.closeChannel(channel, nodeAlias: nodeAlias) { [weak self] in
                info.action()
                self?.delegate?.dismiss()
            }
        case .archiveTransaction:
            info.action()
            delegate?.dismiss()
        }
    }
}
