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
                destructiveActionButton.tintColor = UIColor.zap.nastyGreen
            } else {
                destructiveActionButton.tintColor = UIColor.zap.tomato
            }
            
            setActivityIndicator(hidden: true)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        Style.button.apply(to: destructiveActionButton)
    }
    
    @IBAction private func executeAction(_ sender: Any) {
        guard let info = info else { return }
        switch info.type {
        case let .closeChannel(channel, nodeAlias):
            delegate?.closeChannel(channel, nodeAlias: nodeAlias) { [weak self] in
                self?.setActivityIndicator(hidden: false)
                info.action { result in
                    if let error = result.error {
                        self?.setActivityIndicator(hidden: true)
                        print("😡", error)
                    } else {
                        self?.delegate?.dismiss()
                    }
                }
            }
        case .archiveTransaction, .unarchiveTransaction:
            info.action { [weak self] _ in
                self?.delegate?.dismiss()
            }
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
