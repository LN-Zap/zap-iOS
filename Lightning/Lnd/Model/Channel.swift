//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Foundation

public enum ChannelState {
    case active
    case inactive
    case opening
    case closing
    case forceClosing
    
    public var isClosing: Bool {
        switch self {
        case .closing, .forceClosing:
            return true
        default:
           return false
        }
    }
}

public struct Channel: Equatable {
    public let blockHeight: Int
    public let state: ChannelState
    public let localBalance: Satoshi
    public let remoteBalance: Satoshi
    public let remotePubKey: String
    public let capacity: Satoshi
    public let updateCount: Int?
    public let channelPoint: String
    public let csvDelay: Int
    
    public var fundingTransactionId: String {
        return channelPoint.components(separatedBy: ":")[0]
    }
}

extension Lnrpc_Channel {
    var channelModel: Channel {
        return Channel(
            blockHeight: Int(chanID >> 40),
            state: active ? .active : .inactive,
            localBalance: Satoshi(value: localBalance),
            remoteBalance: Satoshi(value: remoteBalance),
            remotePubKey: remotePubkey,
            capacity: Satoshi(value: capacity),
            updateCount: Int(numUpdates),
            channelPoint: channelPoint,
            csvDelay: Int(csvDelay))
    }
}

extension Lnrpc_PendingChannelsResponse.PendingOpenChannel {
    var channelModel: Channel {
        return Channel(
            blockHeight: Int(confirmationHeight),
            state: .opening,
            localBalance: Satoshi(value: channel.localBalance),
            remoteBalance: Satoshi(value: channel.remoteBalance),
            remotePubKey: channel.remoteNodePub,
            capacity: Satoshi(value: channel.capacity),
            updateCount: 0,
            channelPoint: channel.channelPoint,
            csvDelay: 0)
    }
}

extension Lnrpc_PendingChannelsResponse.ClosedChannel {
    var channelModel: Channel {
        return Channel(
            blockHeight: 0,
            state: .closing,
            localBalance: Satoshi(value: channel.localBalance),
            remoteBalance: Satoshi(value: channel.remoteBalance),
            remotePubKey: channel.remoteNodePub,
            capacity: Satoshi(value: channel.capacity),
            updateCount: 0,
            channelPoint: channel.channelPoint,
            csvDelay: 0)
    }
}

extension Lnrpc_PendingChannelsResponse.ForceClosedChannel {
    var channelModel: Channel {
        return Channel(
            blockHeight: Int(maturityHeight),
            state: .forceClosing,
            localBalance: Satoshi(value: channel.localBalance),
            remoteBalance: Satoshi(value: channel.remoteBalance),
            remotePubKey: channel.remoteNodePub,
            capacity: Satoshi(value: channel.capacity),
            updateCount: 0,
            channelPoint: channel.channelPoint,
            csvDelay: 0)
    }
}
