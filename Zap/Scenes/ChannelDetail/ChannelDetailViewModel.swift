//
//  Zap
//
//  Created by Otto Suess on 10.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

final class ChannelDetailViewModel {
    let viewModel: ViewModel
    let channel: Channel
    
    init(viewModel: ViewModel, channel: Channel) {
        self.viewModel = viewModel
        self.channel = channel
    }
    
    func closeChannel() {
        viewModel.closeChannel(channelPoint: channel.channelPoint)
    }
}
