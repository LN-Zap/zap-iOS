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
    let csvDelay: Int

    let closingTxid: Observable<String?>

    var csvDelayTimeString: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits =  [.year, .month, .day, .hour, .minute]
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 2

        let blockTime: TimeInterval = 10 * 60

        return formatter.string(from: TimeInterval(channel.csvDelay) * blockTime) ?? ""
    }

    init(channel: Channel, channelService: ChannelService) {
        self.channel = channel

        name = Observable(channel.remotePubKey)
        state = Observable(channel.state)

        channelService.node(for: channel.remotePubKey) { [name] in
            if let alias = $0?.alias,
                !alias.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                name.value = alias
            }
        }

        remotePubKey = channel.remotePubKey
        channelPoint = channel.channelPoint
        csvDelay = channel.csvDelay

        localBalance = Observable(channel.localBalance)
        remoteBalance = Observable(channel.remoteBalance)
        closingTxid = Observable(channel.closingTxid)
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
