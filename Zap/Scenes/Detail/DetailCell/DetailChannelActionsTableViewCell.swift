//
//  Zap
//
//  Created by Otto Suess on 06.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class DetailChannelActionsTableViewCell: UITableViewCell {
    struct Info {
        let fundingTransactionUrl: URL
    }
    
    @IBOutlet private weak var fundingTransactionButton: UIButton!
    @IBOutlet private weak var closeButton: UIButton!
    
    weak var delegate: DetailCellDelegate?
    var info: DetailChannelActionsTableViewCell.Info?
    
    @IBAction private func closeChannel(_ sender: Any) {
        delegate?.dismiss()
    }
    
    @IBAction private func displayFundingTransaction(_ sender: Any) {
        guard let info = info else { return }
        delegate?.presentSafariViewController(for: info.fundingTransactionUrl)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        Style.button.apply(to: closeButton, fundingTransactionButton)
        
        fundingTransactionButton.setTitle("Funding Transaction", for: .normal)
        closeButton.setTitle("close", for: .normal)
        closeButton.setTitleColor(UIColor.zap.tomato, for: .normal)
    }
}
