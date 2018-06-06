//
//  Zap
//
//  Created by Otto Suess on 07.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

struct GraphTopologyUpdate {
    let nodeUpdates: [NodeUpdate]
    let channelUpdates: [ChannelEdgeUpdate]
    let closedChannelUpdates: [ClosedChannelUpdate]
}

extension GraphTopologyUpdate {
    init(graphTopologyUpdate: Lnrpc_GraphTopologyUpdate) {
        nodeUpdates = graphTopologyUpdate.nodeUpdates.map(NodeUpdate.init)
        channelUpdates = graphTopologyUpdate.channelUpdates.map(ChannelEdgeUpdate.init)
        closedChannelUpdates = graphTopologyUpdate.closedChans.map(ClosedChannelUpdate.init)
    }
}

struct NodeUpdate {
    let addresses: [String]
    let identityKey: String?
    let alias: String?
}

extension NodeUpdate {
    init(nodeUpdate: Lnrpc_NodeUpdate) {
        addresses = nodeUpdate.addresses
        identityKey = nodeUpdate.identityKey
        alias = nodeUpdate.alias
    }
}

struct ChannelEdgeUpdate {
    let chanId: Int?
//    let chanPoint: ChannelPoint?
    let capacity: Int?
//    let routingPolicy: RoutingPolicy?
    let advertisingNode: String?
    let connectingNode: String?
}

extension ChannelEdgeUpdate {
    init(channelEdgeUpdate: Lnrpc_ChannelEdgeUpdate) {
        chanId = Int(channelEdgeUpdate.chanID)
        capacity = Int(channelEdgeUpdate.capacity)
        advertisingNode = channelEdgeUpdate.advertisingNode
        connectingNode = channelEdgeUpdate.connectingNode
    }
}

struct ClosedChannelUpdate {
    let chanId: Int
    let capacity: Int
    let closedHeight: Int
//    let chanPoint    ChannelPoint    optional
}

extension ClosedChannelUpdate {
    init(closedChannelUpdate: Lnrpc_ClosedChannelUpdate) {
        chanId = Int(closedChannelUpdate.chanID)
        capacity = Int(closedChannelUpdate.capacity)
        closedHeight = Int(closedChannelUpdate.closedHeight)
    }
}
