//
//  Library
//
//  Created by Otto Suess on 15.10.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import SwiftBTC
import UIKit

class ChannelTableViewCell: BondTableViewCell {

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var balanceBackgroundView: UIView!
    @IBOutlet private weak var localAmountView: GradientView!
    @IBOutlet private weak var remoteAmountView: UIView!
    @IBOutlet private weak var localAmountViewWitdthConstraint: NSLayoutConstraint?
    @IBOutlet private weak var remoteAmountViewWidthConstraint: NSLayoutConstraint?

    func update(channelViewModel: ChannelViewModel, maxChannelCapacity: Satoshi) {
        nameLabel.text = channelViewModel.name.value

        if channelViewModel.channel.state == .active {
            channelViewModel.channel.localBalance
                .bind(to: amountLabel.reactive.text, currency: Settings.shared.primaryCurrency)
                .dispose(in: onReuseBag)
        } else {
            amountLabel.text = channelViewModel.channel.state.localized
        }

        localAmountViewWitdthConstraint?.isActive = false
        let localWidthMultiplier = CGFloat(truncating: channelViewModel.channel.localBalance / maxChannelCapacity as NSNumber)
        localAmountViewWitdthConstraint = localAmountView.widthAnchor.constraint(equalTo: balanceBackgroundView.widthAnchor, multiplier: localWidthMultiplier, constant: 0)
        localAmountViewWitdthConstraint?.isActive = true

        remoteAmountViewWidthConstraint?.isActive = false
        let remoteWidthMultiplier = CGFloat(truncating: channelViewModel.channel.remoteBalance / maxChannelCapacity as NSNumber)
        remoteAmountViewWidthConstraint = remoteAmountView.widthAnchor.constraint(equalTo: balanceBackgroundView.widthAnchor, multiplier: remoteWidthMultiplier, constant: 0)
        remoteAmountViewWidthConstraint?.isActive = true
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = UIColor.Zap.deepSeaBlue
        balanceBackgroundView.backgroundColor = UIColor.Zap.seaBlue
        balanceBackgroundView.layer.cornerRadius = 2
        balanceBackgroundView.clipsToBounds = true

        Style.Label.headline.apply(to: nameLabel)
        Style.Label.body.apply(to: amountLabel)

        localAmountView.direction = .horizontal
        remoteAmountView.backgroundColor = .white
    }
}
