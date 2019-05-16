//
//  Library
//
//  Created by 0 on 29.03.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Bond
import ReactiveKit
import SwiftBTC
import UIKit

final class ChannelListHeaderView: UIView {
    struct Segment {
        let title: String
        let color: UIColor
        let source: KeyPath<ChannelListViewModel, Observable<Satoshi>>
        let required: Bool // should this be displayed in the list even though the value is 0
    }

    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var circleGraphView: CircleGraphView!

    let segments: [Segment] = [
        Segment(title: L10n.Scene.Channels.Header.totalCanSend, color: ChannelBalanceColor.local, source: \.totalLocal, required: true),
        Segment(title: L10n.Scene.Channels.Header.totalCanReceive, color: ChannelBalanceColor.remote, source: \.totalRemote, required: true),
        Segment(title: L10n.Scene.Channels.Header.totalPending, color: ChannelBalanceColor.pending, source: \.totalPending, required: false),
        Segment(title: L10n.Scene.Channels.Header.offline, color: ChannelBalanceColor.offline, source: \.totalOffline, required: false)
    ]

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = UIColor.Zap.background
        circleGraphView.backgroundColor = UIColor.Zap.background
        circleGraphView.emptyColor = UIColor.Zap.seaBlue
    }

    func setup(for channelListViewModel: ChannelListViewModel) {
        setupStackView(for: channelListViewModel)
        setupCircleView(for: channelListViewModel)
    }

    func preferredHeight(for channelListViewModel: ChannelListViewModel) -> CGFloat {
        var stackViewHeight: CGFloat = 0
        for segment in segments where segment.required || channelListViewModel[keyPath: segment.source].value > 0 {
            stackViewHeight += 20
        }
        return max(40, stackViewHeight) + 20
    }

    private func setupStackView(for channelListViewModel: ChannelListViewModel) {
        stackView.clear()

        for segment in segments {
            guard segment.required || channelListViewModel[keyPath: segment.source].value > 0 else { continue }

            let circleView = CircleView(frame: .zero)
            circleView.backgroundColor = .clear
            circleView.color = segment.color

            let titleLabel = UILabel(frame: .zero)
            Style.Label.subHeadline.apply(to: titleLabel)
            titleLabel.text = segment.title

            let amountLabel = UILabel(frame: .zero)
            Style.Label.headline.apply(to: amountLabel)
            amountLabel.textAlignment = .right
            channelListViewModel[keyPath: segment.source]
                .bind(to: amountLabel.reactive.text, currency: Settings.shared.primaryCurrency)
                .dispose(in: reactive.bag)

            let horizontalStackView = UIStackView(arrangedSubviews: [circleView, titleLabel, amountLabel])
            horizontalStackView.axis = .horizontal
            horizontalStackView.spacing = 5

            NSLayoutConstraint.activate([
                circleView.widthAnchor.constraint(equalToConstant: 6)
            ])

            stackView.addArrangedSubview(horizontalStackView)
        }
    }

    private func setupCircleView(for channelListViewModel: ChannelListViewModel) {
        let signals: [Signal<Satoshi, Never>] = segments.map { channelListViewModel[keyPath: $0.source].toSignal() }
        Signal(combiningLatest: signals, combine: { _ in 0 })
            .observeNext { [weak self] _ in
                guard let segments = self?.segments else { return }
                self?.circleGraphView.segments = segments.map {
                    let amount = channelListViewModel[keyPath: $0.source].value
                    return CircleGraphView.Segment(amount: amount, color: $0.color)
                }
            }
            .dispose(in: reactive.bag)
    }
}
