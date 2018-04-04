//
//  Zap
//
//  Created by Otto Suess on 22.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import LightningRpc

struct Peer {
    let pubKey: String
    let host: String
}

extension Peer {
    init(peer: LightningRpc.Peer) {
        pubKey = peer.pubKey
        host = peer.address
    }
}
