//
//  Zap
//
//  Created by Otto Suess on 16.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation
import ReactiveKit

public final class ChannelService {
    private let api: LightningApiProtocol

    let all: Signal<[Channel], NoError>
    public let open = Observable<[Channel]>([])
    public let pending = Observable<[Channel]>([])

    init(api: LightningApiProtocol) {
        self.api = api
        
        all = combineLatest(open, pending) {
            return $0 as [Channel] + $1 as [Channel]
        }
    }

    public func update() {
        api.channels { [open] result in
            open.value = result.value ?? []
        }
        
        api.pendingChannels { [pending] result in
            pending.value = result.value ?? []
        }
    }
    
    public func open(pubKey: String, host: String, amount: Satoshi, callback: @escaping (Result<ChannelPoint>) -> Void) {
        api.peers { [weak self, api] peers in
            if peers.value?.contains(where: { $0.pubKey == pubKey }) == true {
                self?.openConnectedChannel(pubKey: pubKey, amount: amount, callback: callback)
            } else {
                api.connect(pubKey: pubKey, host: host) { result in
                    if let error = result.error {
                        callback(Result<ChannelPoint>(error: error))
                    } else {
                        self?.openConnectedChannel(pubKey: pubKey, amount: amount, callback: callback)
                    }
                }
            }
        }
    }
    
    private func openConnectedChannel(pubKey: String, amount: Satoshi, callback: @escaping (Result<ChannelPoint>) -> Void) {
        api.openChannel(pubKey: pubKey, amount: amount) { [weak self] in
            self?.update()
            callback($0)
        }
    }
    
    public func close(_ channel: Channel) {
        let force = channel.state != .active
        api.closeChannel(channelPoint: channel.channelPoint, force: force) { [weak self] _ in
            self?.update()
        }
    }
    
    func alias(for remotePubkey: String, callback: @escaping (String?) -> Void) {
        api.nodeInfo(pubKey: remotePubkey) { result in
            if
                let nodeInfo = result.value,
                let alias = nodeInfo.node.alias,
                alias != "" {
                callback(alias)
            } else {
                callback(nil)
            }
        }
    }
}
