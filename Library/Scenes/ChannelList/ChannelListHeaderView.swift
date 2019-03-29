//
//  Library
//
//  Created by 0 on 29.03.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import ReactiveKit
import UIKit

final class ChannelListHeaderView: UIView {
    @IBOutlet private weak var canSendCircleView: CircleView!
    @IBOutlet private weak var canSendTitleLabel: UILabel!
    @IBOutlet private weak var canSendAmountLabel: UILabel!

    @IBOutlet private weak var canReceiveCircleView: CircleView!
    @IBOutlet private weak var canReceiveTitleLabel: UILabel!
    @IBOutlet private weak var canReceiveAmountLabel: UILabel!

    @IBOutlet private weak var pendingCircleView: CircleView!
    @IBOutlet private weak var pendingTitleLabel: UILabel!
    @IBOutlet private weak var pendingAmountLabel: UILabel!

    @IBOutlet private weak var circleGraphView: CircleGraphView!

    private static let pendingColor = UIColor.Zap.gray

    override func awakeFromNib() {
        super.awakeFromNib()

        Style.Label.subHeadline.apply(to: [canSendTitleLabel, canReceiveTitleLabel, pendingTitleLabel])
        Style.Label.headline.apply(to: [canSendAmountLabel, canReceiveAmountLabel, pendingAmountLabel])

        canSendTitleLabel.text = L10n.Scene.Channels.Header.totalCanSend
        canReceiveTitleLabel.text = L10n.Scene.Channels.Header.totalCanReceive
        pendingTitleLabel.text = L10n.Scene.Channels.Header.totalPending

        backgroundColor = UIColor.Zap.background
        circleGraphView.backgroundColor = UIColor.Zap.background
        circleGraphView.emptyColor = UIColor.Zap.seaBlue

        canSendCircleView.color = UIColor.Zap.lightningOrange
        canReceiveCircleView.color = UIColor.Zap.white
        pendingCircleView.color = ChannelListHeaderView.pendingColor
    }

    func setup(for channelListViewModel: ChannelListViewModel) {
        channelListViewModel.totalLocal
            .bind(to: canSendAmountLabel.reactive.text, currency: Settings.shared.primaryCurrency)
            .dispose(in: reactive.bag)
        channelListViewModel.totalRemote
            .bind(to: canReceiveAmountLabel.reactive.text, currency: Settings.shared.primaryCurrency)
            .dispose(in: reactive.bag)
        channelListViewModel.totalPending
            .bind(to: pendingAmountLabel.reactive.text, currency: Settings.shared.primaryCurrency)
            .dispose(in: reactive.bag)

        combineLatest(channelListViewModel.totalLocal, channelListViewModel.totalRemote, channelListViewModel.totalPending)
            .observeNext { [weak self] in
                self?.circleGraphView.segments = [
                    CircleGraphView.Segment(amount: $0.0, color: UIColor.Zap.lightningOrange),
                    CircleGraphView.Segment(amount: $0.1, color: UIColor.Zap.white),
                    CircleGraphView.Segment(amount: $0.2, color: ChannelListHeaderView.pendingColor)
                ]
            }
            .dispose(in: reactive.bag)
    }
}
