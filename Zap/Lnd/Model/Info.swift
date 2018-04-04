//
//  Zap
//
//  Created by Otto Suess on 27.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import LightningRpc

struct Info {
    let alias: String
    let blockHeight: Int
    let isSyncedToChain: Bool
    let network: Network
    let pubKey: String
    let activeChannelCount: Int
}

extension Info {
    init(getInfoResponse: GetInfoResponse) {
        alias = getInfoResponse.alias
        blockHeight = Int(getInfoResponse.blockHeight)
        isSyncedToChain = getInfoResponse.syncedToChain
        network = getInfoResponse.testnet ? .testnet : .mainnet
        pubKey = getInfoResponse.identityPubkey
        activeChannelCount = Int(getInfoResponse.numActiveChannels)
    }
}
