//
//  Library
//
//  Created by Otto Suess on 07.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

final class ChannelDetailViewModel {
    private let channelViewModel: ChannelViewModel
    
    var presentBlockExplorer: (() -> Void)?
    var closeChannel: (() -> Void)?
    
    var elements: [StackViewElement] {
        let textColor = channelViewModel.color.value.isLight ? UIColor.zap.black : UIColor.zap.white
        let labelStyle = Style.label(color: textColor, fontSize: 14)
        
        var elements = [StackViewElement]()
        elements.append(.label(text: channelViewModel.name.value, style: labelStyle))
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
}
