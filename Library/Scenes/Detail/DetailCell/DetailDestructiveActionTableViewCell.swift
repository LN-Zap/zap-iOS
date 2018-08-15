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
            case archiveTransaction
            case unarchiveTransaction
        }
        
        let title: String
        let type: DestructiveActionType
        let action: (@escaping (Result<Success>) -> Void) -> Void
    }
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var destructiveActionButton: UIButton!
    
    weak var delegate: DetailCellDelegate?
    
    var info: DetailDestructiveActionTableViewCell.Info? {
        didSet {
            guard let info = info else { return }
            destructiveActionButton.setTitle(info.title, for: .normal)
            
            if case .unarchiveTransaction = info.type {
                destructiveActionButton.tintColor = UIColor.Zap.superGreen
            } else {
                destructiveActionButton.tintColor = UIColor.Zap.superRed
            }
            
            setActivityIndicator(hidden: true)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        Style.button().apply(to: destructiveActionButton)
    }
    
    @IBAction private func executeAction(_ sender: Any) {
        guard let info = info else { return }
        
        info.action { [weak self] _ in
            self?.delegate?.dismiss()
        }
    }
    
    private func setActivityIndicator(hidden: Bool) {
        activityIndicator.isHidden = hidden
        destructiveActionButton.isHidden = !hidden
        
        if hidden {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
    }
}
