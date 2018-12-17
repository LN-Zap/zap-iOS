//
//  Zap
//
//  Created by Otto Suess on 05.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import LndRpc
import SwiftBTC

public struct NodeInfo {
    public let node: LightningNode
    public let numChannels: Int
    public let totalCapacity: Int
}

extension NodeInfo {
    init(nodeInfo: LNDNodeInfo) {
        node = LightningNode(lightningNode: nodeInfo.node)
        numChannels = Int(nodeInfo.numChannels)
        totalCapacity = Int(nodeInfo.totalCapacity)
    }
}

public struct LightningNode: Codable {
    public let lastUpdate: Int?
    public let pubKey: String
    public let alias: String?
    public let color: String?
}

extension LightningNode {
    init(lightningNode: LNDLightningNode) {
        lastUpdate = Int(lightningNode.lastUpdate)
        pubKey = lightningNode.pubKey
        alias = lightningNode.alias
        color = lightningNode.color
    }
}
