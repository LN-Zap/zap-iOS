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
    @IBOutlet private weak var localAmountLabel: UILabel!
    @IBOutlet private weak var remoteAmountLabel: UILabel!
    @IBOutlet private weak var localBalanceBackgroundView: UIView!
    @IBOutlet private weak var remoteBalanceBackgroundView: UIView!
    @IBOutlet private weak var localAmountView: GradientView!
    @IBOutlet private weak var remoteAmountView: GradientView!
    @IBOutlet private weak var localAmountViewWitdthConstraint: NSLayoutConstraint?
    @IBOutlet private weak var remoteAmountViewWidthConstraint: NSLayoutConstraint?
    @IBOutlet private weak var stateLabel: UILabel!

    func update(channelViewModel: ChannelViewModel, maxBalance: Satoshi) {

        channelViewModel.name
            .bind(to: nameLabel.reactive.text)
            .dispose(in: reactive.bag)
        channelViewModel.channel.localBalance
            .bind(to: localAmountLabel.reactive.text, currency: Settings.shared.primaryCurrency)
            .dispose(in: onReuseBag)
        channelViewModel.channel.remoteBalance
            .bind(to: remoteAmountLabel.reactive.text, currency: Settings.shared.primaryCurrency)
            .dispose(in: onReuseBag)

        if channelViewModel.channel.state == .active {
            stateLabel.text = nil
        } else {
            stateLabel.text = channelViewModel.channel.state.localized
        }

        localAmountView.layer.cornerRadius = 3
        remoteAmountView.layer.cornerRadius = 3

        localAmountViewWitdthConstraint?.isActive = false
        let localWidthMultiplier = multiplierFor(balance: channelViewModel.channel.localBalance, maxBalance: maxBalance)
        localAmountViewWitdthConstraint = localAmountView.widthAnchor.constraint(equalTo: localBalanceBackgroundView.widthAnchor, multiplier: localWidthMultiplier, constant: 0)
        localAmountViewWitdthConstraint?.isActive = true

        remoteAmountViewWidthConstraint?.isActive = false
        let remoteWidthMultiplier = multiplierFor(balance: channelViewModel.channel.remoteBalance, maxBalance: maxBalance)
        remoteAmountViewWidthConstraint = remoteAmountView.widthAnchor.constraint(equalTo: remoteBalanceBackgroundView.widthAnchor, multiplier: remoteWidthMultiplier, constant: 0)
        remoteAmountViewWidthConstraint?.isActive = true

        remoteAmountView.gradient = UIColor.Zap.lightningBlueGradient

        if channelViewModel.channel.state == .inactive {
            localAmountView.gradient = [ChannelBalanceColor.offline]
        } else if channelViewModel.channel.state == .active {
            localAmountView.gradient = UIColor.Zap.lightningOrangeGradient
        } else {
            localAmountView.gradient = [ChannelBalanceColor.pending]
        }
    }

    private let minBalanceMultiplier = 6 / ((UIScreen.main.bounds.width - 30 - 6) / 2)

    func multiplierFor(balance: Satoshi, maxBalance: Satoshi) -> CGFloat {
        guard balance > 0 else { return 0 }
        let value = CGFloat(truncating: balance / maxBalance as NSNumber)
        let normalized = pow(value, (1 / 1.5))
        assert(normalized >= 0 && normalized <= 1)
        return max(normalized, minBalanceMultiplier)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = UIColor.Zap.deepSeaBlue

        styleBackgroundView(localBalanceBackgroundView)
        styleBackgroundView(remoteBalanceBackgroundView)

        Style.Label.headline.apply(to: nameLabel)
        Style.Label.body.apply(to: stateLabel)

        Style.Label.subHeadline.apply(to: localAmountLabel, remoteAmountLabel)

        localAmountView.direction = .horizontal
        remoteAmountView.backgroundColor = .white
    }

    private func styleBackgroundView(_ view: UIView) {
        view.backgroundColor = UIColor.Zap.seaBlue
        view.layer.cornerRadius = 3
        view.clipsToBounds = true
    }
}
