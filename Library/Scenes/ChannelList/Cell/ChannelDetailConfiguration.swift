//
//  Library
//
//  Created by Otto Suess on 07.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

final class ChannelDetailConfiguration {
    private let channelViewModel: ChannelViewModel
    
    var presentBlockExplorer: (() -> Void)?
    var closeChannel: (() -> Void)?
    
    var elements: [StackViewElement] {
        let verifiedColor = channelViewModel.color.value.verified

        let textColor = verifiedColor.isLight ? UIColor.zap.black : UIColor.zap.white
        
        let labelStyle = Style.Label.custom(color: textColor, fontSize: 14)
        let textStyle = Style.Label.custom(color: textColor, font: UIFont.zap.regular, fontSize: 14)
        let rightAlignedTextStyle = Style.Label.custom(color: textColor, font: UIFont.zap.regular, fontSize: 14, alignment: .right)

        var elements = [StackViewElement]()
        
        let headerElement: StackViewElement
        if channelViewModel.channel.state == .active {
            headerElement = .amountLabel(amount: channelViewModel.channel.localBalance, style: rightAlignedTextStyle)
        } else {
            headerElement = .label(text: channelViewModel.channel.state.localized, style: rightAlignedTextStyle)
        }
        
        elements.append(.horizontalStackView(content: [
            .label(text: channelViewModel.name.value, style: textStyle),
            headerElement
        ]))
        
        if channelViewModel.channel.state.isClosing {
            elements.append(.separator)
            elements.append(.horizontalStackView(content: [
                .label(text: "scene.channel_detail.closing_time.label".localized + ":", style: labelStyle),
                .label(text: channelViewModel.csvDelayTimeString, style: rightAlignedTextStyle)
            ]))
        }
        
        elements.append(.separator)
        elements.append(.verticalStackView(content: [
            .label(text: "scene.channel_detail.remote_pub_key_label".localized + ":", style: labelStyle),
            .label(text: channelViewModel.channel.channelPoint.fundingTxid, style: textStyle)
        ], spacing: -5))
        
        elements.append(.separator)
        let balanceView = BalanceView()
        balanceView.set(localBalance: channelViewModel.channel.localBalance, remoteBalance: channelViewModel.channel.remoteBalance)

        let horizontalStackViewHeight = StackViewElement.horizontalStackView(content: []).height
        
        elements.append(.verticalStackView(content: [
            .custom(view: balanceView, height: 10),
            .horizontalStackView(content: [
                .custom(view: circleIndicatorView(gradient: [UIColor.zap.lightningOrange, UIColor.zap.lightningOrangeGradient]), height: horizontalStackViewHeight),
                .label(text: "scene.channel_detail.local_balance_label".localized + ":", style: labelStyle),
                .amountLabel(amount: channelViewModel.channel.localBalance, style: rightAlignedTextStyle)
            ]),
            .horizontalStackView(content: [
                .custom(view: circleIndicatorView(gradient: [UIColor.zap.seaBlue, UIColor.zap.seaBlueGradient]), height: horizontalStackViewHeight),
                .label(text: "scene.channel_detail.remote_balance_label".localized + ":", style: labelStyle),
                .amountLabel(amount: channelViewModel.channel.remoteBalance, style: rightAlignedTextStyle)
            ])
        ], spacing: 5))
        
        elements.append(.separator)
        elements.append(.horizontalStackView(content: [
            .label(text: "scene.channel_detail.funding_transaction_label".localized + ":", style: labelStyle),
            .button(title: channelViewModel.channel.channelPoint.fundingTxid, style: Style.button(fontSize: 14)) { [weak self] in self?.presentBlockExplorer?() }
        ]))
        
        if !channelViewModel.channel.state.isClosing {
            let closeTitle = channelViewModel.channel.state == .active ? "scene.channel_detail.close_button".localized : "scene.channel_detail.force_close_button".localized
            
            elements.append(.separator)
            elements.append(.button(title: closeTitle, style: Style.button(fontSize: 20)) { [weak self] in self?.closeChannel?() })
        }
        
        return elements
    }

    init(channelViewModel: ChannelViewModel) {
        self.channelViewModel = channelViewModel
    }
    
    private func circleIndicatorView(gradient: [UIColor]) -> UIView {
        let localIndicator = GradientView()
        localIndicator.constrainSize(to: CGSize(width: 10, height: 10))
        localIndicator.translatesAutoresizingMaskIntoConstraints = false
        localIndicator.layer.cornerRadius = 5
        localIndicator.gradient = gradient

        let localIndicatorContainer = UIView()
        localIndicatorContainer.addSubview(localIndicator)
        localIndicatorContainer.constrainCenter(to: localIndicator)

        NSLayoutConstraint.activate([
            localIndicator.leadingAnchor.constraint(equalTo: localIndicatorContainer.leadingAnchor),
            localIndicator.trailingAnchor.constraint(equalTo: localIndicatorContainer.trailingAnchor)
        ])
        
        return localIndicatorContainer
    }
}
