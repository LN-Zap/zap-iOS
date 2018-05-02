//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Foundation

enum ChannelState {
    case active
    case inactive
    case opening
    case closing
    case forceClosing
}

struct Channel: Equatable {
    let state: ChannelState
    let localBalance: Satoshi
    let remoteBalance: Satoshi
    let remotePubKey: String
    let capacity: Satoshi
    let updateCount: Int?
    let channelPoint: String
    
    var fundingTransactionId: String {
        return channelPoint.components(separatedBy: ":")[0]
    }
}

extension Lnrpc_Channel {
    var channelModel: Channel {
        return Channel(
            state: active ? .active : .inactive,
            localBalance: Satoshi(value: localBalance),
            remoteBalance: Satoshi(value: remoteBalance),
            remotePubKey: remotePubkey,
            capacity: Satoshi(value: capacity),
            updateCount: Int(numUpdates),
            channelPoint: channelPoint)
    }
}

extension Lnrpc_PendingChannelsResponse.PendingOpenChannel {
    var channelModel: Channel {
        return Channel(
            state: .opening,
            localBalance: Satoshi(value: channel.localBalance),
            remoteBalance: Satoshi(value: channel.remoteBalance),
            remotePubKey: channel.remoteNodePub,
            capacity: Satoshi(value: channel.capacity),
            updateCount: 0,
            channelPoint: channel.channelPoint)
    }
}

extension Lnrpc_PendingChannelsResponse.ClosedChannel {
    var channelModel: Channel {
        return Channel(
            state: .opening,
            localBalance: Satoshi(value: channel.localBalance),
            remoteBalance: Satoshi(value: channel.remoteBalance),
            remotePubKey: channel.remoteNodePub,
            capacity: Satoshi(value: channel.capacity),
            updateCount: 0,
            channelPoint: channel.channelPoint)
    }
}

extension Lnrpc_PendingChannelsResponse.ForceClosedChannel {
    var channelModel: Channel {
        return Channel(
            state: .opening,
            localBalance: Satoshi(value: channel.localBalance),
            remoteBalance: Satoshi(value: channel.remoteBalance),
            remotePubKey: channel.remoteNodePub,
            capacity: Satoshi(value: channel.capacity),
            updateCount: 0,
            channelPoint: channel.channelPoint)
    }
}
