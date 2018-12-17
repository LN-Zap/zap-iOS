//
//  Zap
//
//  Created by Otto Suess on 07.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import LndRpc

public struct GraphTopologyUpdate {
    let nodeUpdates: [NodeUpdate]
    let channelUpdates: [ChannelEdgeUpdate]
    let closedChannelUpdates: [ClosedChannelUpdate]
}

extension GraphTopologyUpdate {
    init(graphTopologyUpdate: LNDGraphTopologyUpdate) {
        nodeUpdates = graphTopologyUpdate.nodeUpdatesArray.compactMap {
            guard let nodeUpdate = $0 as? LNDNodeUpdate else { return nil }
            return NodeUpdate(nodeUpdate: nodeUpdate)
        }
        channelUpdates = graphTopologyUpdate.channelUpdatesArray.compactMap {
            guard let channelEdgeUpdate = $0 as? LNDChannelEdgeUpdate else { return nil }
            return ChannelEdgeUpdate(channelEdgeUpdate: channelEdgeUpdate)
        }
        closedChannelUpdates = graphTopologyUpdate.closedChansArray.compactMap {
            guard let closedChannelUpdate = $0 as? LNDClosedChannelUpdate else { return nil }
            return ClosedChannelUpdate(closedChannelUpdate: closedChannelUpdate)
        }
    }
}

struct NodeUpdate {
    let addresses: [String]
    let identityKey: String?
    let alias: String?
}

extension NodeUpdate {
    init(nodeUpdate: LNDNodeUpdate) {
        addresses = nodeUpdate.addressesArray.compactMap { $0 as? String }
        identityKey = nodeUpdate.identityKey
        alias = nodeUpdate.alias
    }
}

struct ChannelEdgeUpdate {
    let chanId: Int?
    let capacity: Int?
    let advertisingNode: String?
    let connectingNode: String?
}

extension ChannelEdgeUpdate {
    init(channelEdgeUpdate: LNDChannelEdgeUpdate) {
        chanId = Int(channelEdgeUpdate.chanId)
        capacity = Int(channelEdgeUpdate.capacity)
        advertisingNode = channelEdgeUpdate.advertisingNode
        connectingNode = channelEdgeUpdate.connectingNode
    }
}

struct ClosedChannelUpdate {
    let chanId: Int
    let capacity: Int
    let closedHeight: Int
}

extension ClosedChannelUpdate {
    init(closedChannelUpdate: LNDClosedChannelUpdate) {
        chanId = Int(closedChannelUpdate.chanId)
        capacity = Int(closedChannelUpdate.capacity)
        closedHeight = Int(closedChannelUpdate.closedHeight)
    }
}
