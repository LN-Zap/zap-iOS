//
//  Zap
//
//  Created by Otto Suess on 05.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning
import SwiftBTC
import SwiftLnd

final class ChannelViewModel {
    let channel: Channel

    let state: Observable<ChannelState>
    let name: Observable<String>
    let localBalance: Observable<Satoshi>
    let remoteBalance: Observable<Satoshi>

    let channelPoint: ChannelPoint
    let remotePubKey: String

    let closingTxid: Observable<String?>

    init(channel: Channel, channelService: ChannelService) {
        self.channel = channel

        name = Observable(channel.remotePubKey)
        state = Observable(channel.state)

        channelService.node(for: channel.remotePubKey) { [name] in
            if let alias = $0?.alias,
                !alias.trimAllWhitespacesAndNewlines().isEmpty {
                name.value = alias
            }
        }

        remotePubKey = channel.remotePubKey
        channelPoint = channel.channelPoint

        localBalance = Observable(channel.localBalance)
        remoteBalance = Observable(channel.remoteBalance)

        if let channel = channel as? ClosingChannelType {
            closingTxid = Observable(channel.closingTxid)
        } else {
            closingTxid = Observable(nil)
        }
    }

    func update(channel: Channel) {
        state.value = channel.state
    }
}

extension ChannelViewModel: Equatable {
    static func == (lhs: ChannelViewModel, rhs: ChannelViewModel) -> Bool {
        return lhs.channel.channelPoint == rhs.channel.channelPoint
    }
}
