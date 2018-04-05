//
//  Zap
//
//  Created by Otto Suess on 05.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation
import LightningRpc

struct NodeInfo {
    let node: LightningNode
    let numChannels: Int
    let totalCapacity: Int
}

extension NodeInfo {
    init(nodeInfo: LightningRpc.NodeInfo) {
        node = LightningNode(lightningNode: nodeInfo.node)
        numChannels = Int(nodeInfo.numChannels)
        totalCapacity = Int(nodeInfo.totalCapacity)
    }
}

struct LightningNode {
    let lastUpdate: Int?
    let pubKey: String?
    let alias: String?
    let color: String?
}

extension LightningNode {
    init(lightningNode: LightningRpc.LightningNode) {
        lastUpdate = Int(lightningNode.lastUpdate)
        pubKey = lightningNode.pubKey
        alias = lightningNode.alias
        color = lightningNode.color
    }
}
